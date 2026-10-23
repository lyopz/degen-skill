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
