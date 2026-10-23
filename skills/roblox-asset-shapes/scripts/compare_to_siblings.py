# Blender: compare the active model to sibling models + render a side-by-side check with the reference picture.
# Usage in Blender (Scripting tab or the Blender connector):
#   exec(open(r"<repo>/skills/roblox-asset-shapes/scripts/compare_to_siblings.py").read())
#   report(model="PetA", siblings=["PetB","PetC"], ref=r"C:\...\target.png", out=r"C:\...\checks\peta_vs_ref.png")
import bpy, mathutils

def bbox(name):
    objs = [o for o in bpy.data.objects if o.name == name or (o.parent and o.parent.name == name) or o.name.startswith(name + ".")]
    objs = [o for o in objs if o.type == 'MESH'] or [bpy.data.objects[name]]
    pts = [o.matrix_world @ mathutils.Vector(c) for o in objs for c in o.bound_box]
    mn = mathutils.Vector((min(p.x for p in pts), min(p.y for p in pts), min(p.z for p in pts)))
    mx = mathutils.Vector((max(p.x for p in pts), max(p.y for p in pts), max(p.z for p in pts)))
    tris = sum(sum(len(p.vertices) - 2 for p in o.data.polygons) for o in objs if o.type == 'MESH')
    return mx - mn, tris, len(objs)

def report(model, siblings=(), ref=None, out=None):
    size, tris, parts = bbox(model)
    print(f"{model}: size {size.x:.2f} x {size.y:.2f} x {size.z:.2f}  tris {tris}  parts {parts}")
    for s in siblings:
        if s in bpy.data.objects:
            ss, st, sp = bbox(s)
            print(f"  vs {s}: height ratio {size.z/ss.z:.2f}  width ratio {size.x/ss.x:.2f}  tris {st}  parts {sp}")
    if out:
        sc = bpy.context.scene; sc.render.resolution_x = 1024; sc.render.resolution_y = 1024
        sc.render.film_transparent = False; sc.render.filepath = out
        bpy.ops.render.opengl(write_still=True)
        if ref:
            try:
                from PIL import Image
                a = Image.open(out).convert('RGB').resize((768, 768)); b = Image.open(ref).convert('RGB').resize((768, 768))
                c = Image.new('RGB', (1536, 768), 'white'); c.paste(b, (0, 0)); c.paste(a, (768, 0)); c.save(out.replace('.png', '_side_by_side.png'))
                print("side-by-side:", out.replace('.png', '_side_by_side.png'))
            except Exception as e:
                print("render saved (no PIL for side-by-side):", out, e)
