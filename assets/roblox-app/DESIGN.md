# Degen Roblox app — design notes (for building THIS app, not for Roblox games)

Layout (2026-10-23 redesign): shadcn/21st-style app shell — left sidebar nav with icons + stats, sticky top bar (breadcrumb, Open Roblox Lead, Activity), AI prompt box (textarea + chip selects + mic + send), two-column panels (split plan / recent tasks), Inter + JetBrains Mono. Voice: Web Speech API mic in the prompt box + floating red speak bubble (Ctrl+Space), live transcript bubble. 21st.dev catalog search was down during the redesign — when it's back, swap in matching 21st components (AI input, sidebar, drawer) via the 21st_dev tools.

Skills used to design this app (from the degen-skill library):
- `21st-dev` — components ported to vanilla JS/CSS here:
  - **GlowCard** (`components/spotlight-card.md`): red border glow following the mouse on every `.card`.
  - **Spotlight** (ibelick, from `components/spline-scene.md`): soft red spotlight following the mouse inside the Activity drawer.
- `design-taste-frontend` + `impeccable`: black/red Degen look, one accent color, generous spacing, no generic templates.
- `emil-design-eng` / `animate`: drawer slide `.42s cubic-bezier(.2,.8,.2,1)`, short fades, pulse dot only while working.
- `widget-board` idea: quick idea chips on the Start page.

When changing this app's look, use those skills (and any new 21st.dev components in `skills/21st-dev/components/`). Roblox game work uses the roblox-* skills instead — these design skills are not part of the Roblox team.

Rules (lyopz, 2026-10-24):
- Every change to this app's UI starts with the `21st-dev` skill (+ the 21st_dev MCP search when it's up): reuse or match a 21st component before hand-rolling one.
- Never lose the voice ring (particle orb under the prompt box) or the bubble row look. After any edit, open the page and check the browser console: one JS error stops the ring, the home layout and the bubbles from working.
- Top bubbles: fixed row to the right of the DEGEN logo on the home screen, wraps to a second row on narrow windows; in menu view they sit in the page under the top bar.
