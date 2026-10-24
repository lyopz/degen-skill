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
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

public static class DegenPolish
{
    public const float StudMeters = 0.28f;     // 1 Roblox stud ~ 0.28 m
    const string Root = "Assets/Degen";

    // ---------- 0. Project spots (lyopz 2026-10-24: never build on top of another project) ----------
    // Everything lives in one saved scene, Assets/Degen/Workbench.unity. Each project (Studio place name, or
    // game/projects/name) gets its own zone, 250 m apart, and each asset gets its own free cell inside that zone.
    // Where everything went is kept in ~/RobloxGames/.degen/unity-layout.json (local only, never the repo) and is
    // checked, together with what is really in the scene, before anything is placed. Call UseProject first, every job.
    const float ZoneSpacing = 250f, ZoneSize = 200f, CellGap = 4f, Grid = 8f;
    const int ZonesPerRow = 5;
    const string Workbench = Root + "/Workbench.unity", PrefKey = "Degen.Project";

    [Serializable] public class SpotInfo { public string name, kind, status, export, updated; public float x, z, w, d, heightStuds; public int tris; }
    [Serializable] public class Zone { public string project, created; public int slot; public float x, z; public List<SpotInfo> assets = new List<SpotInfo>(); }
    [Serializable] public class Layout { public string note = "Where DegenPolish put each project and model in the Unity workbench scene. Local only."; public List<Zone> zones = new List<Zone>(); }

    // Opens the workbench, gives the project its own zone (made once, then reused) and makes it the current one.
    public static string UseProject(string project)
    {
        project = (project ?? "").Trim().Replace('\\', '/').Trim('/');
        if (project == "") return Err("give the project: the Studio place name, or <game>/projects/<name>");
        OpenWorkbench();
        var L = Load(); var z = ZoneOf(L, project); Save(L);
        EditorPrefs.SetString(PrefKey, project);
        ZoneObject(z);
        SaveWorkbench();
        FocusZone(z);
        return Where(project);
    }

    // What is where. With a project: its zone and every asset spot. Without: all zones. Also lists "loose" scene
    // objects that are in no zone (stray builds) so you can see them before placing anything.
    public static string Where(string project = null)
    {
        var L = Load();
        var zones = string.IsNullOrEmpty(project) ? L.zones : L.zones.Where(z => z.project == project.Trim().Trim('/')).ToList();
        var loose = SceneManager.GetActiveScene().GetRootGameObjects()
            .Where(g => !g.name.StartsWith("DegenZone_") && !g.name.StartsWith("Degen") && g.GetComponentsInChildren<Renderer>().Length > 0)
            .Select(g => Q(g.name));
        return "{\"current\":" + Q(Current() ?? "") + ",\"layoutFile\":" + Q(LayoutPath()) + ",\"zones\":[" + string.Join(",", zones.Select(z => JsonUtility.ToJson(z))) +
               "],\"loose\":[" + string.Join(",", loose) + "]}";
    }

    // An empty <name>_Root on a free cell of the current project's zone, for things built by hand in Unity
    // (ProBuilder, assembled props, scenes). Parent everything you build under it. Sizes in studs.
    public static string Spot(string name, float widthStuds, float depthStuds)
    {
        string project = Current(); if (project == null) return NoProject();
        OpenWorkbench();
        var L = Load(); var z = ZoneOf(L, project);
        var old = Find(name);
        var s = PlaceSpot(L, z, name, widthStuds * StudMeters, depthStuds * StudMeters, old);
        if (s == null) { Save(L); return Err("zone " + project + " is full"); }
        var root = old ?? new GameObject(name + "_Root");
        root.transform.SetParent(ZoneObject(z).transform, true);
        root.transform.position = new Vector3(s.x, 0, s.z);
        s.kind = s.kind ?? "build"; s.status = s.status ?? "building"; s.updated = Now();
        Save(L); SaveWorkbench();
        Selection.activeGameObject = root;
        return JsonUtility.ToJson(s);
    }

    // Takes an asset out of the scene and the layout (its cell becomes free again).
    public static string Remove(string name)
    {
        string project = Current(); if (project == null) return NoProject();
        var root = Find(name); if (root != null) UnityEngine.Object.DestroyImmediate(root);
        var L = Load(); var z = ZoneOf(L, project); int n = z.assets.RemoveAll(a => a.name == name);
        Save(L); SaveWorkbench();
        return "{\"removed\":" + Q(name) + ",\"spots\":" + n + "}";
    }

    // ---------- 1. Import + place ----------
    // Copies a .glb/.fbx/.obj from disk into Assets/Degen/<project>/<name>/, scales it to heightStuds tall
    // (pivot at bottom centre) and puts it on its own free cell in the current project's zone. Returns spot + Report().
    public static string Import(string sourcePath, string name, float heightStuds)
    {
        string project = Current(); if (project == null) return NoProject();
        if (!File.Exists(sourcePath)) return Err("file not found: " + sourcePath);
        OpenWorkbench();
        string dir = Folder(name);
        string dst = dir + "/" + name + Path.GetExtension(sourcePath).ToLowerInvariant();
        File.Copy(sourcePath, dst, true);
        AssetDatabase.ImportAsset(dst, ImportAssetOptions.ForceUpdate);
        var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(dst);
        if (prefab == null) return Err("Unity could not import " + dst + " (glb needs com.unity.cloud.gltfast)");

        var old = Find(name);
        if (old != null) UnityEngine.Object.DestroyImmediate(old);
        var root = new GameObject(name + "_Root");
        var model = (GameObject)PrefabUtility.InstantiatePrefab(prefab);
        model.transform.SetParent(root.transform, false);
        if (PrefabUtility.IsPartOfPrefabInstance(model)) PrefabUtility.UnpackPrefabInstance(model, PrefabUnpackMode.Completely, InteractionMode.AutomatedAction);

        var b = GetBounds(root);
        if (b.size.y > 1e-5f && heightStuds > 0)
            model.transform.localScale *= heightStuds * StudMeters / b.size.y;
        b = GetBounds(root);
        model.transform.position -= new Vector3(b.center.x, b.min.y, b.center.z);   // bottom centre at the root
        b = GetBounds(root);

        var L = Load(); var z = ZoneOf(L, project);
        var s = PlaceSpot(L, z, name, b.size.x, b.size.z, root);
        if (s == null) { UnityEngine.Object.DestroyImmediate(root); Save(L); return Err("zone " + project + " is full"); }
        root.transform.SetParent(ZoneObject(z).transform, true);
        root.transform.position = new Vector3(s.x, 0, s.z);
        s.kind = "model"; s.status = "imported"; s.heightStuds = heightStuds; s.tris = Tris(root); s.updated = Now();
        Save(L); SaveWorkbench();
        Focus(name);
        return "{\"spot\":" + JsonUtility.ToJson(s) + ",\"report\":" + Report(name) + "}";
    }

    // Frames the model in the Scene view (lit, shaded) so lyopz can watch every step. Called after each change.
    public static string Focus(string name)
    {
        var root = Find(name); if (root == null) return NoRoot(name);
        Selection.activeGameObject = root;
        var sv = SceneView.lastActiveSceneView;
        if (sv == null) sv = EditorWindow.GetWindow<SceneView>();
        sv.Show(); sv.Focus();
        sv.drawGizmos = false;
        sv.sceneLighting = true;
        sv.cameraMode = SceneView.GetBuiltinCameraMode(DrawCameraMode.Textured);
        var b = GetBounds(root);
        sv.LookAt(b.center, Quaternion.Euler(12, 215, 0), Mathf.Max(b.extents.magnitude * 1.6f, 0.2f));
        sv.Repaint();
        return "{\"focused\":" + Q(name) + "}";
    }

    // ---------- 2b. Low poly (lyopz's hard rule: always low poly for Roblox) ----------
    // Budgets (whole model, triangles): pet 1500-3000 (max 4000), prop 300-2000, accessory <= 1500, building/big piece <= 5000.
    static readonly Dictionary<string, int> budgets = new Dictionary<string, int>();
    static int Tris(GameObject root) => root.GetComponentsInChildren<Renderer>()
        .Select(r => r is SkinnedMeshRenderer s ? s.sharedMesh : r.GetComponent<MeshFilter>() ? r.GetComponent<MeshFilter>().sharedMesh : null)
        .Where(m => m != null).Sum(m => m.triangles.Length / 3);

    // PASS/FAIL against the budget. Remembers it, so ExportForRoblox refuses an over-budget model.
    public static string Budget(string name, int maxTris)
    {
        var root = Find(name); if (root == null) return NoRoot(name);
        budgets[BKey(name)] = maxTris;
        int t = Tris(root);
        return "{\"triangles\":" + t + ",\"budget\":" + maxTris + ",\"result\":" + (t <= maxTris ? "\"PASS\"" : "\"FAIL: run Decimate or Customuse retopology\"") + "}";
    }

    // Cuts every mesh down so the whole model fits maxTris (UnityMeshSimplifier, MIT; keeps UV seams so textures stay put).
    // Big cuts (more than ~60%) can look lumpy: then prefer Customuse retopology with a face limit and re-import.
    public static string Decimate(string name, int maxTris)
    {
        var root = Find(name); if (root == null) return NoRoot(name);
        budgets[BKey(name)] = maxTris;
        int before = Tris(root);
        if (before <= maxTris) return Budget(name, maxTris);
        var tSimp = AppDomain.CurrentDomain.GetAssemblies().Select(a => a.GetType("UnityMeshSimplifier.MeshSimplifier")).FirstOrDefault(t => t != null);
        if (tSimp == null) return Err("UnityMeshSimplifier missing: run unity-setup.ps1 again (adds com.whinarn.unitymeshsimplifier)");
        string dir = Folder(name);
        float quality = Mathf.Clamp01((float)maxTris / before * 0.97f);
        int i = 0;
        foreach (var r in root.GetComponentsInChildren<Renderer>())
        {
            var mf = r.GetComponent<MeshFilter>(); var sk = r as SkinnedMeshRenderer;
            var mesh = sk ? sk.sharedMesh : mf ? mf.sharedMesh : null; if (mesh == null) continue;
            var simp = Activator.CreateInstance(tSimp);
            var optProp = tSimp.GetProperty("SimplificationOptions");
            if (optProp != null)
            {
                object opt = optProp.GetValue(simp);
                opt.GetType().GetField("PreserveUVSeamEdges")?.SetValue(opt, true);
                opt.GetType().GetField("PreserveBorderEdges")?.SetValue(opt, true);
                optProp.SetValue(simp, opt);
            }
            tSimp.GetMethod("Initialize", new[] { typeof(Mesh) }).Invoke(simp, new object[] { mesh });
            tSimp.GetMethod("SimplifyMesh", new[] { typeof(float) }).Invoke(simp, new object[] { quality });
            var low = (Mesh)tSimp.GetMethod("ToMesh").Invoke(simp, null);
            low.name = mesh.name + "_low";
            low.RecalculateBounds();
            AssetDatabase.CreateAsset(low, dir + "/" + Safe(name) + "_low" + (i++) + ".asset");
            if (sk) sk.sharedMesh = low; else mf.sharedMesh = low;
        }
        AssetDatabase.SaveAssets();
        Focus(name);
        int after = Tris(root);
        return "{\"before\":" + before + ",\"after\":" + after + ",\"budget\":" + maxTris + ",\"result\":" + (after <= maxTris ? "\"PASS\"" : "\"FAIL\"") + (after < before * 0.4f ? ",\"note\":\"big cut: check Shots for lumps; Customuse retopology may look cleaner\"" : "") + "}";
    }

    // ---------- 2. Check ----------
    // Triangles, size in studs, materials and textures. Use before and after every change.
    public static string Report(string name)
    {
        var root = Find(name); if (root == null) return NoRoot(name);
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
        var root = Find(name); if (root == null) return NoRoot(name);
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
        Focus(name);
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
        var root = Find(name); if (root == null) return NoRoot(name);
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
        Focus(name);
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
        var root = Find(name); if (root == null) return NoRoot(name);
        Directory.CreateDirectory(outDir);
        var b = GetBounds(root);
        var hidden = HideAllBut(root);
        try {
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
        } finally { foreach (var g in hidden) if (g) g.SetActive(true); }
    }

    // ---------- 5. Export for Roblox ----------
    // Writes <outDir>/<name>.glb (main) + <name>.fbx (fallback) + SurfaceAppearance maps (<name>_color/_normal/_metalness/_roughness/_emissive.png,
    // max 1024 px) + roblox.json (sizes, colours, which map goes where). Studio: File > Import 3D the .glb.
    public static string ExportForRoblox(string name, string outDir, int maxTex)
    {
        var root = Find(name); if (root == null) return NoRoot(name);
        var at = root.transform.position;
        root.transform.position = Vector3.zero;   // the file gets the model at the origin, not at its workbench spot
        string j;
        try { j = ExportAtOrigin(root, name, outDir, maxTex); }
        finally { root.transform.position = at; }
        if (!j.StartsWith("{\"error\"")) Mark(name, "exported", Path.Combine(outDir, name + ".glb"), Tris(root));
        return j;
    }

    static string ExportAtOrigin(GameObject root, string name, string outDir, int maxTex)
    {
        Directory.CreateDirectory(outDir);
        if (maxTex <= 0 || maxTex > 1024) maxTex = 1024;
        if (budgets.TryGetValue(BKey(name), out int cap) && Tris(root) > cap)
            return Err("over the low-poly budget (" + Tris(root) + " > " + cap + " tris). Run Decimate(name, " + cap + ") or Customuse retopology first.");
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

    // Only looks inside the current project's zone, so a same-named model in another project is never touched.
    static GameObject Find(string name)
    {
        string p = Current(); if (p == null) return null;
        OpenWorkbench();
        var zone = SceneManager.GetActiveScene().GetRootGameObjects().FirstOrDefault(g => g.name == "DegenZone_" + Key(p));
        if (zone == null) return null;
        foreach (Transform t in zone.transform) if (t.name == name + "_Root" || t.name == name) return t.gameObject;
        return null;
    }
    static string NoRoot(string name) => Current() == null ? NoProject() : Err("no " + name + "_Root in project " + Current() + " (Import or Spot it first)");
    static string NoProject() => Err("no project set: call DegenPolish.UseProject(\"<Studio place name>\") first");
    static string Current() { var p = EditorPrefs.GetString(PrefKey, ""); return p == "" ? null : p; }
    static string Key(string project) => Safe(project.Replace("/", "__"));
    static string BKey(string name) => (Current() ?? "") + "|" + name;
    static string Now() => DateTime.Now.ToString("yyyy-MM-dd HH:mm");
    static string Folder(string name)
    {
        if (!AssetDatabase.IsValidFolder(Root)) AssetDatabase.CreateFolder("Assets", "Degen");
        string pk = Key(Current() ?? "no-project"), pd = Root + "/" + pk;
        if (!AssetDatabase.IsValidFolder(pd)) AssetDatabase.CreateFolder(Root, pk);
        string d = pd + "/" + Safe(name);
        if (!AssetDatabase.IsValidFolder(d)) AssetDatabase.CreateFolder(pd, Safe(name));
        return d;
    }

    static string LayoutPath() => Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), "RobloxGames", ".degen", "unity-layout.json");
    static Layout Load()
    {
        try { var p = LayoutPath(); if (File.Exists(p)) return JsonUtility.FromJson<Layout>(File.ReadAllText(p)) ?? new Layout(); }
        catch (Exception e) { Debug.LogWarning("[Degen] unity-layout.json unreadable, kept as .bad: " + e.Message); try { File.Copy(LayoutPath(), LayoutPath() + ".bad", true); } catch { } }
        return new Layout();
    }
    static void Save(Layout L)
    {
        var p = LayoutPath(); Directory.CreateDirectory(Path.GetDirectoryName(p));
        File.WriteAllText(p + ".tmp", JsonUtility.ToJson(L, true));
        if (File.Exists(p)) File.Replace(p + ".tmp", p, null); else File.Move(p + ".tmp", p);
    }
    static void Mark(string name, string status, string export, int tris)
    {
        string p = Current(); if (p == null) return;
        var L = Load(); var s = ZoneOf(L, p).assets.FirstOrDefault(a => a.name == name); if (s == null) return;
        s.status = status; if (export != null) s.export = export; s.tris = tris; s.updated = Now(); Save(L);
    }

    // The project's zone. A new one takes the first free slot whose ground has nothing on it yet.
    static Zone ZoneOf(Layout L, string project)
    {
        var z = L.zones.FirstOrDefault(a => a.project == project);
        if (z != null) return z;
        var inScene = SceneManager.GetActiveScene().GetRootGameObjects().FirstOrDefault(g => g.name == "DegenZone_" + Key(project));
        if (inScene != null)   // the layout file was lost: take the zone back where it already is
        {
            z = new Zone { project = project, slot = L.zones.Count == 0 ? 0 : L.zones.Max(a => a.slot) + 1, x = inScene.transform.position.x, z = inScene.transform.position.z, created = Now() };
            L.zones.Add(z); return z;
        }
        var boxes = SceneBoxes(null);
        for (int slot = 0; ; slot++)
        {
            if (L.zones.Any(a => a.slot == slot)) continue;
            float x = (slot % ZonesPerRow) * ZoneSpacing, zz = (slot / ZonesPerRow) * ZoneSpacing;
            if (L.zones.Any(a => Mathf.Abs(a.x - x) < ZoneSpacing && Mathf.Abs(a.z - zz) < ZoneSpacing)) continue;
            if (boxes.Any(bb => Overlap(bb, x + ZoneSize / 2, zz + ZoneSize / 2, ZoneSize, ZoneSize))) continue;
            z = new Zone { project = project, slot = slot, x = x, z = zz, created = Now() };
            L.zones.Add(z); return z;
        }
    }
    static GameObject ZoneObject(Zone z)
    {
        string n = "DegenZone_" + Key(z.project);
        var go = SceneManager.GetActiveScene().GetRootGameObjects().FirstOrDefault(g => g.name == n);
        if (go == null) { go = new GameObject(n); go.transform.position = new Vector3(z.x, 0, z.z); }
        return go;
    }

    // A free cell for a footprint (metres) inside the zone: no other spot (any project) and nothing in the scene under it.
    // Keeps the asset's old cell when it still fits.
    static SpotInfo PlaceSpot(Layout L, Zone z, string name, float w, float d, GameObject self)
    {
        float cw = Mathf.Max(Grid, w + CellGap), cd = Mathf.Max(Grid, d + CellGap);
        var others = L.zones.SelectMany(a => a.assets).Where(a => !(a.name == name && z.assets.Contains(a))).ToList();
        var boxes = SceneBoxes(self);
        bool Free(float px, float pz) => !others.Any(o => Overlap(new Bounds(new Vector3(o.x, 0, o.z), new Vector3(o.w, 1, o.d)), px, pz, cw, cd))
                                         && !boxes.Any(b => Overlap(b, px, pz, cw, cd));
        var s = z.assets.FirstOrDefault(a => a.name == name);
        if (s != null && Free(s.x, s.z)) { s.w = cw; s.d = cd; return s; }
        for (float gz = 0; gz + cd <= ZoneSize; gz += Grid)
            for (float gx = 0; gx + cw <= ZoneSize; gx += Grid)
            {
                float x = z.x + gx + cw / 2, y = z.z + gz + cd / 2;
                if (!Free(x, y)) continue;
                if (s == null) { s = new SpotInfo { name = name }; z.assets.Add(s); }
                s.x = x; s.z = y; s.w = cw; s.d = cd; return s;
            }
        return null;
    }
    static List<Bounds> SceneBoxes(GameObject self)
    {
        var mine = self ? new HashSet<Renderer>(self.GetComponentsInChildren<Renderer>()) : new HashSet<Renderer>();
        return UnityEngine.Object.FindObjectsByType<Renderer>(FindObjectsSortMode.None).Where(r => r.enabled && !mine.Contains(r)).Select(r => r.bounds).ToList();
    }
    static bool Overlap(Bounds b, float x, float z, float w, float d) =>
        b.max.x > x - w / 2 && b.min.x < x + w / 2 && b.max.z > z - d / 2 && b.min.z < z + d / 2;

    static void OpenWorkbench()
    {
        var s = SceneManager.GetActiveScene();
        if (s.path == Workbench) return;
        if (!AssetDatabase.IsValidFolder(Root)) AssetDatabase.CreateFolder("Assets", "Degen");
        if (s.isDirty)   // keep whatever was there before (never throw work away)
            EditorSceneManager.SaveScene(s, string.IsNullOrEmpty(s.path) ? Root + "/Before-workbench-" + DateTime.Now.ToString("yyyyMMdd-HHmmss") + ".unity" : s.path);
        if (File.Exists(Workbench)) EditorSceneManager.OpenScene(Workbench, OpenSceneMode.Single);
        else EditorSceneManager.SaveScene(EditorSceneManager.NewScene(NewSceneSetup.DefaultGameObjects, NewSceneMode.Single), Workbench);
    }
    static void SaveWorkbench() { var s = SceneManager.GetActiveScene(); if (s.path == Workbench) EditorSceneManager.SaveScene(s); }
    static void FocusZone(Zone z)
    {
        var sv = SceneView.lastActiveSceneView ?? EditorWindow.GetWindow<SceneView>();
        var go = ZoneObject(z); Selection.activeGameObject = go;
        var b = GetBounds(go); if (b.size == Vector3.zero) b = new Bounds(new Vector3(z.x + 10, 0, z.z + 10), Vector3.one * 10);
        sv.LookAt(b.center, Quaternion.Euler(30, 215, 0), Mathf.Max(b.extents.magnitude * 1.6f, 6f)); sv.Repaint();
    }
    // Shots only show the model: everything else in the scene is switched off for a moment.
    static List<GameObject> HideAllBut(GameObject root)
    {
        var off = new List<GameObject>();
        foreach (var g in SceneManager.GetActiveScene().GetRootGameObjects())
        {
            if (g.GetComponent<Light>() || !g.activeSelf) continue;
            if (root.transform.IsChildOf(g.transform))
            {
                foreach (Transform t in g.transform) if (t.gameObject != root && t.gameObject.activeSelf) { t.gameObject.SetActive(false); off.Add(t.gameObject); }
                continue;
            }
            g.SetActive(false); off.Add(g);
        }
        return off;
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
// Makes MCP for Unity connect by itself whenever this project opens (lyopz: "connect whenever, like everything else").
// Matches the transport unity-setup.ps1 wrote (stdio by default; stdio bridges auto-start) and turns on Auto-Start for HTTP.
[InitializeOnLoad]
public static class DegenMcpAutoConnect
{
    static DegenMcpAutoConnect()
    {
        try
        {
            string cfg = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), "RobloxGames", ".degen", "unity-mcp.json");
            bool http = File.Exists(cfg) && File.ReadAllText(cfg).Contains("\"url\"");
            EditorPrefs.SetBool("MCPForUnity.AutoStartOnLoad", true);
            if (EditorPrefs.GetBool("MCPForUnity.UseHttpTransport", true) == http) return;
            var cache = AppDomain.CurrentDomain.GetAssemblies().Select(a => a.GetType("MCPForUnity.Editor.Services.EditorConfigurationCache")).FirstOrDefault(t => t != null);
            var inst = cache?.GetProperty("Instance")?.GetValue(null);
            var set = cache?.GetMethod("SetUseHttpTransport");
            if (inst != null && set != null) set.Invoke(inst, new object[] { http });
            else EditorPrefs.SetBool("MCPForUnity.UseHttpTransport", http);
            Debug.Log("[Degen] MCP for Unity transport set to " + (http ? "HTTP" : "stdio") + ". If it doesn't connect, reopen the project once.");
        }
        catch (Exception e) { Debug.LogWarning("[Degen] auto-connect setup failed: " + e.Message); }
    }
}
#endif

