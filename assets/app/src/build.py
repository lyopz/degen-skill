"""Rebuild assets/app/index.html from template.html + media. Run from anywhere: python assets/app/src/build.py
Inlines skills/particle-media/particle-media.js and embeds the images/video so the page works offline.
The skill list itself is NOT baked in for the app; launch.ps1 writes skills.js from the skill files each launch."""
import base64, json, os, re, sys
SRC = os.path.dirname(os.path.abspath(__file__)); APP = os.path.dirname(SRC); REPO = os.path.dirname(os.path.dirname(APP))
sys.path.insert(0, os.path.join(REPO, 'assets'))
from make_assets import CORE
h = open(os.path.join(SRC, 'template.html'), encoding='utf-8').read()
s = h.index('/* particle-media.js'); e = h.index('})(typeof window', s) + len("})(typeof window !== 'undefined' ? window : this);")
h = h[:s] + open(os.path.join(REPO, 'skills/particle-media/particle-media.js'), encoding='utf-8').read().strip() + h[e:]
raw = []
for n in sorted(os.listdir(os.path.join(REPO, 'skills'))):
    f = os.path.join(REPO, 'skills', n, 'SKILL.md')
    if not os.path.exists(f): continue
    t = open(f, encoding='utf-8').read(); m = re.search(r'^description:\s*(.*)$', t, re.M); d = m.group(1).strip() if m else ''
    if d in ('|', '>', '|-', '>-'): d = ' '.join(l.strip() for l in t[m.end():].split('\n---')[0].strip().splitlines())
    raw.append({'n': n, 'd': d.strip('"')})
b64 = lambda f: base64.b64encode(open(os.path.join(SRC, f), 'rb').read()).decode()
for k in ['hero', 'swarm', 'cards']: h = h.replace(f'__{k.upper()}__', 'data:image/jpeg;base64,' + b64(k + '.jpg'))
h = h.replace('__VID__', b64('hero.mp4'))
h = h.replace('__SKILLS_RAW__', json.dumps(raw, ensure_ascii=False).replace('</', '<\\/'))
h = h.replace('__CORE__', json.dumps({n: t.title() for t, _, it in CORE for n, _ in it}))
names = [r['n'] for r in raw]; src = {}
for row in open(os.path.join(REPO, 'reviews/SKILLS_REGISTRY.md'), encoding='utf-8').read().split('## Reviewed')[0].splitlines():
    c = [x.strip() for x in row.split('|')]
    if len(c) < 4 or not c[3] or c[1] in ('Repo', '---'): continue
    repo = 'lyopz (own)' if c[1].startswith('lyopz') else c[1]
    for f in re.findall(r'`([\w.-]+)/?`', c[3]):
        if f in names: src[f] = repo
for n in names:
    if n in src: continue
    if re.match(r'(omni-|cli-|config-)', n): src[n] = 'diegosouzapw/OmniRoute'
    elif re.match(r'(agentdb|reasoningbank|swarm|hive-mind|sparc|stream-chain|worker-|hooks-|agentic-|pair-prog|verification|performance-an|skill-builder|github-|browser|dual-)', n): src[n] = 'ruvnet/ruflo'
    elif re.match(r'(animate|animation|emil|apple-design|ask-sonner|break-ui|find-animation|improve-anim|review-anim|pick-ui|prototype|mobile-native|write-swift)', n): src[n] = 'emilkowalski/skills'
h = h.replace('__SRC__', json.dumps(src))
h = h.replace('__PLAIN__', json.dumps({n: d for t, _, it in CORE for n, d in it}))
h = h.replace('<title>Degen Skills</title>', '<title>Degen Skills</title>\n<link rel="icon" href="icon.png">\n<script src="skills.js"></script>', 1)
open(os.path.join(APP, 'index.html'), 'w', encoding='utf-8').write(h)
# single-file preview (for the claude.ai artifact): model inlined
open(os.path.join(SRC, 'preview.html'), 'w', encoding='utf-8').write(h.replace('<script src="skills.js"></script>', '<script>window.CHICKEN="' + b64('chicken.glb') + '";</script>'))
print('wrote assets/app/index.html,', len(raw), 'skills as fallback')
