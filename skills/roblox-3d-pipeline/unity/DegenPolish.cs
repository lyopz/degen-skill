// DegenPolish: Unity editor helpers for the Roblox 3D pipeline (roblox-3d-pipeline skill).
// unity-setup.ps1 copies this into <unity project>/Assets/Editor/. Call from MCP for Unity's
// execute_code tool, e.g.  return DegenPolish.Import(@"C:\...\pet.glb", "pet", 4f);
// Every public method takes/returns plain strings (JSON) so it works over MCP.
// Needs: com.unity.cloud.gltfast (.glb import), com.unity.formats.fbx (FBX export). URP project.
#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;

public static class DegenPolish
{
    public const float StudMeters = 0.28f;     // 1 Roblox stud ~ 0.28 m
    const string Root = "Assets/Degen";

    // ---------- 1. Import + place ----------
    // Copies a .glb/.fbx/.obj from disk into Assets/Degen/<name>/, places it at the origin
    // (pivot at bottom centre), scaled so it is heightStuds tall. Returns Report().
    public static string Import(string sourcePath, string name, float heightStuds)
    {
        if (!File.Exists(sourcePath)) return Err("file not found: " + sourcePath);
        string dir = Folder(name);
        string dst = dir + "/" + name + Path.GetExtension(sourcePath).ToLowerInvariant();
        File.Copy(sourcePath, dst, true);
        AssetDatabase.ImportAsset(dst, ImportAssetOptions.ForceUpdate);
        var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(dst);
        if (prefab == null) return Err("Unity could not import " + dst + " (glb needs com.unity.cloud.gltfast)");

        var old = GameObject.Find(name + "_Root");
        if (old != null) UnityEngine.Object.DestroyImmediate(old);
        var root = new GameObject(name + "_Root");
        var model = (GameObject)PrefabUtility.InstantiatePrefab(prefab);
        model.transform.SetParent(root.transform, false);
        if (PrefabUtility.IsPartOfPrefabInstance(model)) PrefabUtility.UnpackPrefabInstance(model, PrefabUnpackMode.Completely, InteractionMode.AutomatedAction);

        var b = GetBounds(root);
        if (b.size.y > 1e-5f && heightStuds > 0)
            model.transform.localScale *= heightStuds * StudMeters / b.size.y;
        b = GetBounds(root);
        model.transform.position -= new Vector3(b.center.x, b.min.y, b.center.z);   // bottom centre at origin
        Selection.activeGameObject = root;
        return Report(name);
    }

    // ---------- 2. Check ----------
    // Triangles, size in studs, materials and textures. Use before and after every change.
    public static string Report(string name)
    {
        var root = Find(name); if (root == null) return Err("no " + name + "_Root in scene");
        int tris = 0, verts = 0, meshes = 0;
        var mats = new List<string>();
        foreach (var r in root.GetComponentsInChildren<Renderer>())
        {
            Mesh m = r is SkinnedMeshRenderer s ? s.sharedMesh : r.GetComponent<MeshFilter>()?.sharedMesh;
            if (m != null) { tris += m.triangles.Length / 3; verts += m.vertexCount; meshes++; }
            foreach (var mat in r.sharedMaterials.Where(x => x != null))
            {
                var tex = TexOf(mat, "_BaseMap", "baseColorTexture", "_MainTex");
                mats.Add(Q(mat.name) + ":{\"shader\":" + Q(mat.shader.name) + ",\"baseTex\":" + (tex ? "\"" + tex.width + "x" + tex.height + "\"" : "null") + "}");
            }
        }
        var size = GetBounds(root).size / StudMeters;
        return "{\"name\":" + Q(name) + ",\"meshes\":" + meshes + ",\"triangles\":" + tris + ",\"vertices\":" + verts +
               ",\"sizeStuds\":[" + F(size.x) + "," + F(size.y) + "," + F(size.z) + "],\"materials\":{" + string.Join(",", mats.Distinct()) + "}}";
    }

    // ---------- 3. Materials ----------
    // Converts glTF/Standard materials to URP Lit (copies base colour, normal, metal/rough, emission)
    // so manage_material and PaintRegions work on one set of property names.
    public static string ToUrpLit(string name)
    {
        var root = Find(name); if (root == null) return Err("no " + name + "_Root in scene");
        var lit = Shader.Find("Universal Render Pipeline/Lit"); if (lit == null) return Err("URP Lit shader missing (make the project from the Universal 3D template)");
        string dir = Folder(name);
        var done = new Dictionary<Material, Material>();
        foreach (var r in root.GetComponentsInChildren<Renderer>())
        {
            var list = r.sharedMaterials;
            for (int i = 0; i < list.Length; i++)
            {
                var src = list[i]; if (src == null) continue;
                if (src.shader == lit) continue;
                if (!done.TryGetValue(src, out var m))
                {
                    m = new Material(lit) { name = name + "_" + Safe(src.name) };
                    var baseTex = TexOf(src, "baseColorTexture", "_BaseMap", "_MainTex");
                    if (baseTex) m.SetTexture("_BaseMap", baseTex);
                    m.SetColor("_BaseColor", ColOf(src, Color.white, "baseColorFactor", "_BaseColor", "_Color"));
                    var nrm = TexOf(src, "normalTexture", "_BumpMap");
                    if (nrm) { m.SetTexture("_BumpMap", nrm); m.EnableKeyword("_NORMALMAP"); }
                    float metal = FloatOf(src, 0f, "metallicFactor", "_Metallic");
                    float rough = src.HasProperty("roughnessFactor") ? src.GetFloat("roughnessFactor") : 1f - FloatOf(src, 0.5f, "_Smoothness", "_Glossiness");
                    var mr = TexOf(src, "metallicRoughnessTexture");
                    if (mr)   // glTF: G = roughness, B = metal  ->  URP: R = metal, A = smoothness
                    {
                        var px = Read(mr, true, out int w, out int h);
                        for (int p = 0; p < px.Length; p++) px[p] = new Color(px[p].b * metal, 0, 0, 1f - px[p].g * rough);
                        m.SetTexture("_MetallicGlossMap", Save(dir + "/" + m.name + "_mg.png", px, w, h, false));
                        m.EnableKeyword("_METALLICSPECGLOSSMAP"); m.SetFloat("_Smoothness", 1f);
                    }
                    else { m.SetFloat("_Metallic", metal); m.SetFloat("_Smoothness", 1f - rough); }
                    var em = TexOf(src, "emissiveTexture", "_EmissionMap");
                    var emc = ColOf(src, Color.black, "emissiveFactor", "_EmissionColor");
                    if (em || emc.maxColorComponent > 0.001f)
                    {
                        if (em) m.SetTexture("_EmissionMap", em);
                        m.SetColor("_EmissionColor", em && emc.maxColorComponent < 0.001f ? Color.white : emc);
                        m.EnableKeyword("_EMISSION"); m.globalIlluminationFlags = MaterialGlobalIlluminationFlags.RealtimeEmissive;
                    }
                    AssetDatabase.CreateAsset(m, dir + "/" + m.name + ".mat");
                    done[src] = m;
                }
                list[i] = m;
            }
            r.sharedMaterials = list;
        }
        AssetDatabase.SaveAssets();
        return "{\"converted\":" + done.Count + "}";
    }

    // The premium-pet look from one texture: picks regions by colour and gives each its own
    // material response (matte body, glossy armor, gold metal trim, glowing crystals).
    // rulesJson: {"rules":[{"label":"gold","hueMin":35,"hueMax":60,"satMin":0.35,"valMin":0.45,"metal":1,"smooth":0.8,"glow":0},
    //                      {"label":"crystal","hueMin":170,"hueMax":210,"satMin":0.4,"valMin":0.5,"metal":0,"smooth":0.9,"glow":0.6}],
    //             "defaultMetal":0,"defaultSmooth":0.25}
    // First matching rule wins. Hue in degrees (0-360), sat/val 0-1 (satMax/valMax optional), glow = emission strength (keep <= 1, ed likes subtle glow).
    public static string PaintRegions(string name, string rulesJson)
    {
        var root = Find(name); if (root == null) return Err("no " + name + "_Root in scene");
        var cfg = JsonUtility.FromJson<RuleSet>(rulesJson); if (cfg == null || cfg.rules == null) return Err("bad rulesJson");
        string dir = Folder(name);
        var sb = new StringBuilder("{");
        foreach (var m in Mats(root))
        {
            var baseTex = m.GetTexture("_BaseMap");
            if (baseTex == null) { sb.Append(Q(m.name) + ":\"no base texture, set _Metallic/_Smoothness with manage_material\","); continue; }
            var px = Read(baseTex, false, out int w, out int h);
            var mg = new Color[px.Length]; var em = new Color[px.Length];
            var counts = new int[cfg.rules.Length];
            for (int p = 0; p < px.Length; p++)
            {
                Color.RGBToHSV(px[p], out float hu, out float s, out float v); hu *= 360f;
                float metal = cfg.defaultMetal, smooth = cfg.defaultSmooth, glow = 0;
                for (int k = 0; k < cfg.rules.Length; k++)
                {
                    var r = cfg.rules[k];
                    bool hueOk = r.hueMin <= r.hueMax ? hu >= r.hueMin && hu <= r.hueMax : hu >= r.hueMin || hu <= r.hueMax;
                    if (hueOk && s >= r.satMin && s <= (r.satMax > 0 ? r.satMax : 1f) && v >= r.valMin && v <= (r.valMax > 0 ? r.valMax : 1f)) { metal = r.metal; smooth = r.smooth; glow = r.glow; counts[k]++; break; }
                }
                mg[p] = new Color(metal, 0, 0, smooth);
                em[p] = new Color(px[p].r * glow, px[p].g * glow, px[p].b * glow, 1);
            }
            m.SetTexture("_MetallicGlossMap", Save(dir + "/" + m.name + "_mg.png", mg, w, h, false));
            m.EnableKeyword("_METALLICSPECGLOSSMAP"); m.SetFloat("_Smoothness", 1f);
            if (counts.Where((c, k) => cfg.rules[k].glow > 0).Sum() > 0)
            {
                m.SetTexture("_EmissionMap", Save(dir + "/" + m.name + "_em.png", em, w, h, true));
                m.SetColor("_EmissionColor", Color.white); m.EnableKeyword("_EMISSION");
            }
            EditorUtility.SetDirty(m);
            sb.Append(Q(m.name) + ":{" + string.Join(",", cfg.rules.Select((r, k) => Q(r.label) + ":" + F(100f * counts[k] / px.Length) + "")) + "},");
        }
        AssetDatabase.SaveAssets();
        return sb.ToString().TrimEnd(',') + "} (percent of texture per rule; 0% = rule missed, widen its hue)";
    }

    // ---------- 4. Look ----------
    // Soft studio light + rim light + neutral sky, close to Roblox "Future" lighting, for judging the model.
    public static string StudioLight()
    {
        foreach (var l in UnityEngine.Object.FindObjectsByType<Light>(FindObjectsSortMode.None)) if (l.name.StartsWith("Degen")) UnityEngine.Object.DestroyImmediate(l.gameObject);
        MakeLight("DegenKey", new Vector3(40, -30, 0), 1.2f, new Color(1f, 0.97f, 0.92f), true);
        MakeLight("DegenRim", new Vector3(20, 160, 0), 0.9f, new Color(0.75f, 0.85f, 1f), false);
        RenderSettings.ambientMode = UnityEngine.Rendering.AmbientMode.Trilight;
        RenderSettings.ambientSkyColor = new Color(0.62f, 0.66f, 0.72f);
        RenderSettings.ambientEquatorColor = new Color(0.45f, 0.45f, 0.48f);
        RenderSettings.ambientGroundColor = new Color(0.25f, 0.24f, 0.24f);
        return "{\"ok\":true}";
    }

    // Renders `views` shots around the model (white background, like the ChatGPT picture) to outDir.
    // Compare them side by side with the picture before exporting.
    public static string Shots(string name, string outDir, int views, int size)
    {
        var root = Find(name); if (root == null) return Err("no " + name + "_Root in scene");
        Directory.CreateDirectory(outDir);
        var b = GetBounds(root);
        var go = new GameObject("DegenShotCam"); var cam = go.AddComponent<Camera>();
        cam.clearFlags = CameraClearFlags.SolidColor; cam.backgroundColor = Color.white; cam.fieldOfView = 30;
        var rt = new RenderTexture(size, size, 24, RenderTextureFormat.ARGB32, RenderTextureReadWrite.sRGB) { antiAliasing = 8 };
        cam.targetTexture = rt;
        float dist = b.extents.magnitude / Mathf.Sin(cam.fieldOfView * 0.5f * Mathf.Deg2Rad) * 1.05f;
        var paths = new List<string>();
        for (int i = 0; i < Mathf.Max(1, views); i++)
        {
            float yaw = 35f + i * 360f / Mathf.Max(1, views);   // first view = three-quarter, like the picture
            var dir = Quaternion.Euler(12, yaw, 0) * Vector3.back;
            cam.transform.position = b.center + dir * dist; cam.transform.LookAt(b.center);
            cam.Render();
            RenderTexture.active = rt;
            var tex = new Texture2D(size, size, TextureFormat.RGB24, false); tex.ReadPixels(new Rect(0, 0, size, size), 0, 0); tex.Apply();
            RenderTexture.active = null;
            string p = Path.Combine(outDir, name + "_view" + i + ".png"); File.WriteAllBytes(p, tex.EncodeToPNG()); paths.Add(p);
            UnityEngine.Object.DestroyImmediate(tex);
        }
        cam.targetTexture = null; UnityEngine.Object.DestroyImmediate(rt); UnityEngine.Object.DestroyImmediate(go);
        return "{\"shots\":[" + string.Join(",", paths.Select(Q)) + "]}";
    }

    // ---------- 5. Export for Roblox ----------
    // Writes <outDir>/<name>.glb (main) + <name>.fbx (fallback) + SurfaceAppearance maps (<name>_color/_normal/_metalness/_roughness/_emissive.png,
    // max 1024 px) + roblox.json (sizes, colours, which map goes where). Studio: File > Import 3D the .glb.
    public static string ExportForRoblox(string name, string outDir, int maxTex)
    {
        var root = Find(name); if (root == null) return Err("no " + name + "_Root in scene");
        Directory.CreateDirectory(outDir);
        if (maxTex <= 0 || maxTex > 1024) maxTex = 1024;
        string glb = Glb(root, Path.Combine(outDir, name + ".glb"), name, out string glbErr);
        string fbx = Path.Combine(outDir, name + ".fbx");
        var exporter = AppDomain.CurrentDomain.GetAssemblies().Select(a => a.GetType("UnityEditor.Formats.Fbx.Exporter.ModelExporter")).FirstOrDefault(t => t != null);
        var export = exporter?.GetMethod("ExportObject", new[] { typeof(string), typeof(UnityEngine.Object) });
        if (export != null) export.Invoke(null, new object[] { fbx, root }); else fbx = null;
        if (glb == null && fbx == null) return Err("no exporter: add com.unity.cloud.gltfast and/or com.unity.formats.fbx (" + glbErr + ")");

        var mats = Mats(root).ToList();
        var json = new StringBuilder("{\"glb\":" + (glb == null ? "null" : Q(glb)) + ",\"fbx\":" + (fbx == null ? "null" : Q(fbx)) + ",\"sizeStuds\":");
        var sz = GetBounds(root).size / StudMeters; json.Append("[" + F(sz.x) + "," + F(sz.y) + "," + F(sz.z) + "],\"materials\":[");
        int n = 0;
        foreach (var m in mats)
        {
            string tag = mats.Count == 1 ? name : name + "_" + (n++);
            var outs = new List<string>();
            int w, h;
            var bt = m.GetTexture("_BaseMap");
            if (bt) outs.Add("\"color\":" + Q(Write(outDir, tag + "_color.png", Resize(Read(bt, false, out w, out h), ref w, ref h, maxTex), w, h)));
            var nt = m.GetTexture("_BumpMap");
            if (nt) { var px = Read(nt, true, out w, out h); Unpack(px); outs.Add("\"normal\":" + Q(Write(outDir, tag + "_normal.png", Resize(px, ref w, ref h, maxTex), w, h))); }
            var mg = m.GetTexture("_MetallicGlossMap");
            if (mg)
            {
                var px = Read(mg, true, out w, out h); px = Resize(px, ref w, ref h, maxTex);
                float sm = m.GetFloat("_Smoothness");
                outs.Add("\"metalness\":" + Q(Write(outDir, tag + "_metalness.png", px.Select(c => new Color(c.r, c.r, c.r, 1)).ToArray(), w, h)));
                outs.Add("\"roughness\":" + Q(Write(outDir, tag + "_roughness.png", px.Select(c => { float r = 1f - c.a * sm; return new Color(r, r, r, 1); }).ToArray(), w, h)));
            }
            else outs.Add("\"metal\":" + F(m.GetFloat("_Metallic")) + ",\"roughnessValue\":" + F(1f - m.GetFloat("_Smoothness")));
            var et = m.IsKeywordEnabled("_EMISSION") ? m.GetTexture("_EmissionMap") : null;
            if (et) outs.Add("\"emissive\":" + Q(Write(outDir, tag + "_emissive.png", Resize(Read(et, false, out w, out h), ref w, ref h, maxTex), w, h)));
            var c0 = m.GetColor("_BaseColor");
            outs.Add("\"baseColor\":[" + F(c0.r) + "," + F(c0.g) + "," + F(c0.b) + "]");
            json.Append("{\"material\":" + Q(m.name) + "," + string.Join(",", outs) + "},");
        }
        string j = json.ToString().TrimEnd(',') + "],\"studio\":\"File > Import 3D the glb (textures come along as SurfaceAppearance; fbx is the fallback). Missing or flat maps: add a SurfaceAppearance per MeshPart: ColorMap=color, NormalMap=normal, MetalnessMap=metalness, RoughnessMap=roughness; emissive -> SurfaceAppearance emissive mask if Studio has it, else small Neon parts / PointLight\"}";
        File.WriteAllText(Path.Combine(outDir, "roblox.json"), j);
        return j;
    }

    // glTF binary export through glTFast (keeps URP Lit colour/normal/metal-rough/emission in one file).
    static string Glb(GameObject root, string path, string name, out string err)
    {
        err = null;
        try
        {
            Type T(string n) => AppDomain.CurrentDomain.GetAssemblies().Select(a => a.GetType(n)).FirstOrDefault(t => t != null);
            Type tExp = T("GLTFast.Export.GameObjectExport"), tSet = T("GLTFast.Export.ExportSettings"), tFmt = T("GLTFast.Export.GltfFormat");
            if (tExp == null || tSet == null || tFmt == null) { err = "glTFast export not found"; return null; }
            var settings = Activator.CreateInstance(tSet);
            tSet.GetProperty("Format").SetValue(settings, Enum.Parse(tFmt, "Binary"));
            var ctor = tExp.GetConstructors().First(c => c.GetParameters().Length == 5);
            var exp = ctor.Invoke(new object[] { settings, null, null, null, null });
            tExp.GetMethod("AddScene", new[] { typeof(GameObject[]), typeof(string) }).Invoke(exp, new object[] { new[] { root }, name });
            var save = tExp.GetMethod("SaveToFileAndDispose", new[] { typeof(string), typeof(bool), typeof(System.Threading.CancellationToken) });
            var task = (System.Threading.Tasks.Task<bool>)save.Invoke(exp, new object[] { path, true, System.Threading.CancellationToken.None });
            if (task.Result) return path;
            err = "glTFast export returned false (see Console)"; return null;
        }
        catch (Exception e) { err = (e.InnerException ?? e).Message; return null; }
    }

    // ---------- helpers ----------
    [Serializable] public class Rule { public string label; public float hueMin, hueMax, satMin, satMax, valMin, valMax, metal, smooth, glow; }
    [Serializable] public class RuleSet { public Rule[] rules; public float defaultMetal = 0f, defaultSmooth = 0.25f; }

    static GameObject Find(string name) => GameObject.Find(name + "_Root") ?? GameObject.Find(name);
    static string Folder(string name)
    {
        if (!AssetDatabase.IsValidFolder(Root)) AssetDatabase.CreateFolder("Assets", "Degen");
        string d = Root + "/" + Safe(name);
        if (!AssetDatabase.IsValidFolder(d)) AssetDatabase.CreateFolder(Root, Safe(name));
        return d;
    }
    static Bounds GetBounds(GameObject root)
    {
        var rs = root.GetComponentsInChildren<Renderer>();
        if (rs.Length == 0) return new Bounds(root.transform.position, Vector3.zero);
        var b = rs[0].bounds; foreach (var r in rs) b.Encapsulate(r.bounds); return b;
    }
    static IEnumerable<Material> Mats(GameObject root) =>
        root.GetComponentsInChildren<Renderer>().SelectMany(r => r.sharedMaterials).Where(m => m != null).Distinct();
    static Texture TexOf(Material m, params string[] props) { foreach (var p in props) if (m.HasProperty(p) && m.GetTexture(p)) return m.GetTexture(p); return null; }
    static Color ColOf(Material m, Color d, params string[] props) { foreach (var p in props) if (m.HasProperty(p)) return m.GetColor(p); return d; }
    static float FloatOf(Material m, float d, params string[] props) { foreach (var p in props) if (m.HasProperty(p)) return m.GetFloat(p); return d; }

    // Reads any texture (even non-readable / compressed) by blitting it to a RenderTexture.
    static Color[] Read(Texture t, bool linear, out int w, out int h)
    {
        w = t.width; h = t.height;
        var rt = RenderTexture.GetTemporary(w, h, 0, RenderTextureFormat.ARGB32, linear ? RenderTextureReadWrite.Linear : RenderTextureReadWrite.sRGB);
        Graphics.Blit(t, rt);
        var prev = RenderTexture.active; RenderTexture.active = rt;
        var tex = new Texture2D(w, h, TextureFormat.RGBA32, false, linear); tex.ReadPixels(new Rect(0, 0, w, h), 0, 0); tex.Apply();
        RenderTexture.active = prev; RenderTexture.ReleaseTemporary(rt);
        var px = tex.GetPixels(); UnityEngine.Object.DestroyImmediate(tex); return px;
    }
    static Color[] Resize(Color[] px, ref int w, ref int h, int max)
    {
        if (w <= max && h <= max) return px;
        float s = (float)max / Mathf.Max(w, h); int nw = Mathf.Max(1, Mathf.RoundToInt(w * s)), nh = Mathf.Max(1, Mathf.RoundToInt(h * s));
        var src = new Texture2D(w, h, TextureFormat.RGBA32, false); src.SetPixels(px); src.Apply();
        var o = new Color[nw * nh];
        for (int y = 0; y < nh; y++) for (int x = 0; x < nw; x++) o[y * nw + x] = src.GetPixelBilinear((x + 0.5f) / nw, (y + 0.5f) / nh);
        UnityEngine.Object.DestroyImmediate(src); w = nw; h = nh; return o;
    }
    // Normal maps imported as "Normal map" come back packed (DXT5nm: x in A, y in G). Rebuild plain RGB.
    static void Unpack(Color[] px)
    {
        float r = 0, b = 0; int step = Mathf.Max(1, px.Length / 4096), n = 0;
        for (int i = 0; i < px.Length; i += step) { r += px[i].r; b += px[i].b; n++; }
        r /= n; b /= n;
        bool dxt5nm = r > 0.9f && b > 0.9f, bc5 = b < 0.1f;
        if (!dxt5nm && !bc5) return;
        for (int i = 0; i < px.Length; i++)
        {
            float x = (dxt5nm ? px[i].a : px[i].r) * 2 - 1, y = px[i].g * 2 - 1;
            float z = Mathf.Sqrt(Mathf.Clamp01(1 - x * x - y * y));
            px[i] = new Color(x * 0.5f + 0.5f, y * 0.5f + 0.5f, z * 0.5f + 0.5f, 1);
        }
    }
    static Texture2D Save(string assetPath, Color[] px, int w, int h, bool srgb)
    {
        File.WriteAllBytes(assetPath, Encode(px, w, h));
        AssetDatabase.ImportAsset(assetPath, ImportAssetOptions.ForceUpdate);
        var imp = (TextureImporter)AssetImporter.GetAtPath(assetPath);
        imp.sRGBTexture = srgb; imp.SaveAndReimport();
        return AssetDatabase.LoadAssetAtPath<Texture2D>(assetPath);
    }
    static string Write(string dir, string file, Color[] px, int w, int h) { string p = Path.Combine(dir, file); File.WriteAllBytes(p, Encode(px, w, h)); return p; }
    static byte[] Encode(Color[] px, int w, int h)
    {
        var t = new Texture2D(w, h, TextureFormat.RGBA32, false); t.SetPixels(px); t.Apply();
        var bytes = t.EncodeToPNG(); UnityEngine.Object.DestroyImmediate(t); return bytes;
    }
    static void MakeLight(string n, Vector3 euler, float intensity, Color c, bool shadows)
    {
        var go = new GameObject(n); var l = go.AddComponent<Light>();
        l.type = LightType.Directional; l.intensity = intensity; l.color = c; l.shadows = shadows ? LightShadows.Soft : LightShadows.None;
        go.transform.rotation = Quaternion.Euler(euler);
    }
    static string Safe(string s) => new string(s.Select(ch => char.IsLetterOrDigit(ch) || ch == '-' || ch == '_' ? ch : '_').ToArray());
    static string Q(string s) => "\"" + (s ?? "").Replace("\\", "\\\\").Replace("\"", "\\\"") + "\"";
    static string F(float f) => f.ToString("0.###", System.Globalization.CultureInfo.InvariantCulture);
    static string Err(string m) => "{\"error\":" + Q(m) + "}";
}
#endif
