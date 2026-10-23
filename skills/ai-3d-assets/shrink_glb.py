"""Shrink a GLB by resizing its textures (the usual bulk). Standard library + Pillow.
Usage: python shrink_glb.py in.glb out.glb [--size 1024] [--quality 82]
Roblox: use --size 1024 (its max texture size)."""
import argparse, io, json, struct
from PIL import Image

ap = argparse.ArgumentParser(); ap.add_argument('src'); ap.add_argument('dst')
ap.add_argument('--size', type=int, default=1024); ap.add_argument('--quality', type=int, default=82)
a = ap.parse_args()
b = open(a.src, 'rb').read()
jl = struct.unpack('<I', b[12:16])[0]; j = json.loads(b[20:20 + jl])
o = 20 + jl; bl = struct.unpack('<I', b[o:o + 4])[0]; bin_ = b[o + 8:o + 8 + bl]
views = {}
for img in j.get('images', []):
    v = j['bufferViews'][img['bufferView']]; s = v.get('byteOffset', 0)
    im = Image.open(io.BytesIO(bin_[s:s + v['byteLength']]))
    if max(im.size) > a.size:
        im = im.resize((a.size, a.size) if im.size[0] == im.size[1] else (a.size, int(im.size[1] * a.size / im.size[0])), Image.LANCZOS)
    out = io.BytesIO()
    if img.get('mimeType') == 'image/png' and im.mode in ('RGBA', 'LA'): im.save(out, 'PNG', optimize=True)
    else: im.convert('RGB').save(out, 'JPEG', quality=a.quality); img['mimeType'] = 'image/jpeg'
    views[img['bufferView']] = out.getvalue()
new = bytearray()
for i, v in enumerate(j['bufferViews']):
    s = v.get('byteOffset', 0); d = views.get(i, bin_[s:s + v['byteLength']])
    while len(new) % 4: new += b'\0'
    v['byteOffset'] = len(new); v['byteLength'] = len(d); new += d
while len(new) % 4: new += b'\0'
j['buffers'][0]['byteLength'] = len(new)
js = json.dumps(j, separators=(',', ':')).encode()
while len(js) % 4: js += b' '
open(a.dst, 'wb').write(b'glTF' + struct.pack('<II', 2, 28 + len(js) + len(new)) + struct.pack('<I', len(js)) + b'JSON' + js + struct.pack('<I', len(new)) + b'BIN\0' + bytes(new))
print(f'{a.src}: {len(b)//1024} KB -> {a.dst}: {(28+len(js)+len(new))//1024} KB')
