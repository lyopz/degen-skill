"""Cut a flat green (#00FF00) background out of a picture -> transparent PNG.
Used for pet mouth decals (white teeth can't be cut out of a white background).
Usage: python chroma-key.py in.png out.png [--size 1024]
"""
import sys
from PIL import Image


def main():
    args = sys.argv[1:]
    if len(args) < 2:
        sys.exit(__doc__)
    size = int(args[args.index("--size") + 1]) if "--size" in args else 1024
    im = Image.open(args[0]).convert("RGBA")
    px = im.load()
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, _ = px[x, y]
            green = g - max(r, b)  # how much greener than the rest
            if green > 90:
                px[x, y] = (0, 0, 0, 0)
            elif green > 30:  # soft edge + remove green spill
                a = int(255 * (90 - green) / 60)
                px[x, y] = (r, min(g, max(r, b)), b, a)
    box = im.getbbox()
    if box:
        im = im.crop(box)
    im.thumbnail((size, size))
    im.save(args[1])
    print(args[1], im.size)


if __name__ == "__main__":
    main()
