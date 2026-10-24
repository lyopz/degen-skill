"""Turn ChatGPT pictures into Roblox particle textures.
Needs Pillow: pip install pillow

  python vfx_texture.py alpha  in.png out.png [--size 512] [--keep-color]
      Picture drawn white/bright on a BLACK background -> PNG with a real transparent background.
      Brightness becomes alpha. Default makes the texture pure white (tint it in Studio with Color),
      --keep-color keeps the picture's own colors. Size is rounded to a power of two (max 1024).

  python vfx_texture.py flipbook out.png frame1.png frame2.png ... [--grid 4]
      Packs frames (any count up to grid*grid) into a 1024x1024 sheet for FlipbookLayout Grid2x2/4x4/8x8.
      Frames are run through the same black-to-alpha step and get a small margin so edges don't bleed.

  python vfx_texture.py split sheet.png out.png --grid 4 [--keep-color]
      ChatGPT made the whole sheet in one picture? Cleans it, re-centers each cell and rebuilds a clean 1024 sheet.
"""
import sys, argparse
from PIL import Image, ImageOps

def pow2(n):
    p = 8
    while p * 2 <= n and p < 1024: p *= 2
    return p

def to_alpha(img, keep_color=False, gamma=1.0, stretch=True):
    img = img.convert('RGB')
    lum = ImageOps.grayscale(img)
    if gamma != 1.0: lum = lum.point(lambda v: int(255 * (v / 255) ** gamma))
    if stretch: lum = ImageOps.autocontrast(lum, cutoff=1)  # darkest -> 0 (clear), brightest -> 255 (solid)
    if keep_color:
        # un-premultiply so colors stay bright where alpha is low
        px, a = img.load(), lum.load()
        out = Image.new('RGBA', img.size)
        o = out.load()
        for y in range(img.size[1]):
            for x in range(img.size[0]):
                al = a[x, y]
                r, g, b = px[x, y]
                k = 255 / al if al else 0
                o[x, y] = (min(255, int(r * k)), min(255, int(g * k)), min(255, int(b * k)), al)
        return out
    out = Image.new('RGBA', img.size, (255, 255, 255, 0))
    out.putalpha(lum)
    return out

def fit(img, size, margin=0.06, crop=True):
    """crop=True trims empty space (single textures); False keeps the frame as drawn (flipbooks keep growth/fade)."""
    img = img.copy()
    box = img.getbbox()
    if crop and box: img = img.crop(box)
    inner = int(size * (1 - 2 * margin))
    k = inner / max(img.width, img.height)
    img = img.resize((max(1, int(img.width * k)), max(1, int(img.height * k))), Image.LANCZOS)
    cell = Image.new('RGBA', (size, size), (255, 255, 255, 0))
    cell.paste(img, ((size - img.width) // 2, (size - img.height) // 2), img)
    return cell

def sheet(frames, grid, out):
    cell = 1024 // grid
    s = Image.new('RGBA', (1024, 1024), (255, 255, 255, 0))
    for i, f in enumerate(frames[:grid * grid]):
        s.paste(fit(f, cell, crop=False), ((i % grid) * cell, (i // grid) * cell))
    s.save(out)
    print('wrote', out, f'(1024x1024, Grid{grid}x{grid}, {min(len(frames), grid*grid)} frames)')

def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('mode', choices=['alpha', 'flipbook', 'split'])
    ap.add_argument('files', nargs='+')
    ap.add_argument('--size', type=int, default=512)
    ap.add_argument('--grid', type=int, default=4, choices=[2, 4, 8])
    ap.add_argument('--keep-color', action='store_true')
    ap.add_argument('--gamma', type=float, default=1.0, help='>1 = softer glow edges get more transparent')
    a = ap.parse_args()
    if a.mode == 'alpha':
        src, out = a.files[0], a.files[1]
        img = to_alpha(Image.open(src), a.keep_color, a.gamma)
        size = pow2(min(a.size, max(img.size)))
        fit(img, size, margin=0.02).save(out)
        print('wrote', out, f'({size}x{size})')
    elif a.mode == 'flipbook':
        out, srcs = a.files[0], a.files[1:]
        sheet([to_alpha(Image.open(f), a.keep_color, a.gamma, stretch=False) for f in srcs], a.grid, out)  # same brightness scale for every frame
    else:
        src, out = a.files[0], a.files[1]
        img = to_alpha(Image.open(src), a.keep_color, a.gamma)
        w, h = img.width // a.grid, img.height // a.grid
        cells = [img.crop((x * w, y * h, (x + 1) * w, (y + 1) * h)) for y in range(a.grid) for x in range(a.grid)]
        sheet(cells, a.grid, out)

if __name__ == '__main__':
    main()
