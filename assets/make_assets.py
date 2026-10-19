"""Builds the black-and-red front-page images. Run from the repo root: python assets/make_assets.py"""
from html import escape

BG = "#0b0b0d"
PANEL = "#141417"
LINE = "#2a2a30"
RED = "#e11d2e"
RED_SOFT = "#ff4d5e"
WHITE = "#f5f5f7"
GREY = "#a1a1aa"
FONT = "Segoe UI, Helvetica Neue, Helvetica, Arial, sans-serif"
MONO = "Cascadia Code, Consolas, Menlo, monospace"

STATS = [("89", "skills"), ("85", "agents"), ("159", "commands"), ("7", "sources")]

CORE = [
    ("CODING", "Write and fix code", [
        ("ponytail", "Writes the least code that fully does the job"),
        ("ponytail-review", "Checks your latest changes for bugs"),
        ("ponytail-audit", "Checks a whole project, ranks what to fix"),
        ("ponytail-debt", "Lists shortcuts taken so you fix them later"),
        ("debugging-and-error-recovery", "Finds why something broke, fixes the cause"),
        ("security-and-hardening", "Finds ways hackers could get in, closes them"),
    ]),
    ("DESIGN", "Make it look good", [
        ("ui-ux-pro-max", "Huge library of colors, fonts and layouts"),
        ("frontend-ui-engineering", "Builds pages that work on every screen"),
        ("ui-styling", "Styling, with 29 font families included"),
        ("design", "Logos, icons, mockups and social images"),
        ("design-system", "Keeps colors and buttons the same everywhere"),
        ("brand", "Sets your brand's look and voice"),
        ("banner-design", "Banners for posts, ads and websites"),
        ("slides", "Builds presentations"),
    ]),
    ("PLANNING", "Think it through", [
        ("idea-refine", "Turns a rough idea into a clear plan"),
        ("graphify", "Maps a project so Claude gets it faster"),
        ("project-map", "Draws a glowing map of your project to explore"),
        ("skill-intake", "Adds new skills, removes ones you don't want"),
    ]),
]

PACKS = [
    ("26", "SWARMS", "Ruflo", "A team of AI helpers that split up a big job and work on it at the same time."),
    ("45", "OMNIROUTE", "AI gateway", "Run lots of AI models through one place, switch when one runs out, track what you spend."),
]


def t(x, y, s, size=18, fill=WHITE, weight=400, family=FONT, anchor="start", ls=0):
    return (f'<text x="{x}" y="{y}" font-family="{family}" font-size="{size}" font-weight="{weight}" '
            f'fill="{fill}" text-anchor="{anchor}" letter-spacing="{ls}">{escape(s)}</text>')


def banner():
    w, h = 1200, 320
    o = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">',
         '<defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1">'
         f'<stop offset="0" stop-color="{RED}"/><stop offset="1" stop-color="#7a0b15"/></linearGradient>'
         '<pattern id="grid" width="32" height="32" patternUnits="userSpaceOnUse">'
         f'<path d="M32 0H0V32" fill="none" stroke="{LINE}" stroke-width="1"/></pattern></defs>',
         f'<rect width="{w}" height="{h}" rx="18" fill="{BG}"/>',
         f'<rect width="{w}" height="{h}" rx="18" fill="url(#grid)" opacity="0.55"/>',
         f'<polygon points="{w-420},0 {w},0 {w},{h} {w-620},{h}" fill="url(#g)"/>',
         f'<polygon points="{w-470},0 {w-430},0 {w-630},{h} {w-670},{h}" fill="{RED}" opacity="0.5"/>',
         f'<rect x="56" y="64" width="10" height="112" fill="{RED}"/>',
         t(86, 112, "DEGEN SKILLS", 58, WHITE, 800, ls=2),
         t(88, 158, "lyopz's toolbox for Claude Code", 24, GREY, 500),
         t(88, 206, "Install once. Claude picks the right skill on its own.", 18, WHITE, 400)]
    x = 88
    for num, label in STATS:
        bw = 48 + 11.5 * len(num) + 8.6 * len(label)
        o.append(f'<rect x="{x}" y="236" width="{bw}" height="40" rx="20" fill="{PANEL}" stroke="{RED}" stroke-width="1.5"/>')
        o.append(t(x + 20, 263, num, 19, RED_SOFT, 800))
        o.append(t(x + 28 + 11.5 * len(num), 263, label, 16, WHITE, 500))
        x += bw + 12
    o.append(t(w - 70, 290, "CLAUDE CODE", 15, WHITE, 700, anchor="end", ls=4))
    o.append('</svg>')
    return "\n".join(o)


def catalog():
    w = 1200
    pad = 56
    y = 0
    body = []

    y += 70
    body.append(t(pad, y, "WHAT'S INSIDE", 30, WHITE, 800, ls=3))
    body.append(f'<rect x="{pad}" y="{y + 14}" width="64" height="4" fill="{RED}"/>')
    y += 50
    body.append(t(pad, y, "You don't need to remember any of these. Just ask Claude for what you want.", 18, GREY))
    y += 30

    for title, sub, items in CORE:
        y += 34
        rows = len(items)
        box_h = 70 + rows * 40
        body.append(f'<rect x="{pad}" y="{y}" width="{w - 2 * pad}" height="{box_h}" rx="14" fill="{PANEL}" stroke="{LINE}"/>')
        body.append(f'<rect x="{pad}" y="{y}" width="8" height="{box_h}" rx="4" fill="{RED}"/>')
        body.append(t(pad + 32, y + 44, title, 22, RED_SOFT, 800, ls=3))
        body.append(t(pad + 32 + 17.5 * len(title) + 14, y + 44, "· " + sub, 18, GREY, 500))
        body.append(t(w - pad - 28, y + 44, f"{rows} skills", 16, GREY, 600, anchor="end"))
        ry = y + 92
        for i, (name, desc) in enumerate(items):
            if i:
                body.append(f'<line x1="{pad + 32}" y1="{ry - 27}" x2="{w - pad - 28}" y2="{ry - 27}" stroke="{LINE}"/>')
            body.append(f'<circle cx="{pad + 38}" cy="{ry - 6}" r="4" fill="{RED}"/>')
            body.append(t(pad + 54, ry, name, 17, WHITE, 600, MONO))
            body.append(t(pad + 430, ry, desc, 18, GREY))
            ry += 40
        y += box_h

    y += 34
    tile_w = (w - 2 * pad - 24) // 2
    tile_h = 190
    for i, (num, title, sub, desc) in enumerate(PACKS):
        x = pad + i * (tile_w + 24)
        body.append(f'<rect x="{x}" y="{y}" width="{tile_w}" height="{tile_h}" rx="14" fill="url(#rg)"/>')
        body.append(t(x + 30, y + 78, num, 56, WHITE, 800))
        body.append(t(x + 30 + 34 * len(num) + 16, y + 56, title, 22, WHITE, 800, ls=3))
        body.append(t(x + 30 + 34 * len(num) + 16, y + 80, sub + " pack", 16, "#ffd5d9", 500))
        # wrap description
        words, line, lines = desc.split(), "", []
        for wd in words:
            if len(line) + len(wd) + 1 > 52:
                lines.append(line)
                line = wd
            else:
                line = (line + " " + wd).strip()
        lines.append(line)
        for j, ln in enumerate(lines):
            body.append(t(x + 30, y + 124 + j * 26, ln, 18, WHITE, 500))
    y += tile_h + 56

    head = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{y}" viewBox="0 0 {w} {y}">',
            '<defs><linearGradient id="rg" x1="0" y1="0" x2="1" y2="1">'
            f'<stop offset="0" stop-color="{RED}"/><stop offset="1" stop-color="#6d0a13"/></linearGradient></defs>',
            f'<rect width="{w}" height="{y}" rx="18" fill="{BG}"/>']
    return "\n".join(head + body + ['</svg>'])


if __name__ == "__main__":
    open("assets/banner.svg", "w").write(banner())
    open("assets/catalog.svg", "w").write(catalog())
    print("wrote assets/banner.svg, assets/catalog.svg")
