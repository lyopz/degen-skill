---
name: 21st-dev
description: "Lyopz's saved 21st.dev React components (shadcn + Tailwind + TypeScript), with a standard way to install them into a project. Use when lyopz asks for a 21st.dev component, names one in components/ (e.g. \"spotlight card\", \"glow card\"), or wants a fancy prebuilt UI piece: glowing borders, glow or spotlight effects that follow the mouse, glowing cards, interactive 3D scenes (Spline), heroes, buttons or backgrounds. Check components/ before building one of these from scratch."
---

<!-- lyopz's own collection. Each file in components/ is a 21st.dev "copy prompt" he saved. -->

# 21st.dev Components

Saved components live in `components/` next to this file, one `.md` per component, exactly as 21st.dev exported them (code + demo + notes).

| File | Component | What it is |
|---|---|---|
| `components/spotlight-card.md` | `GlowCard` | Card with a glowing border/spotlight that follows the mouse. Colors: blue, purple, green, red, orange. Sizes sm/md/lg or custom. |
| `components/spline-scene.md` | `SplineScene` (+ `Spotlight`, shadcn `Card`) | Interactive 3D scene from Spline in a dark hero card, with a soft spotlight that follows the mouse. Needs `@splinetool/runtime`, `@splinetool/react-spline`, `framer-motion`. Note: the demo passes `fill="white"` to `Spotlight`, which this Spotlight doesn't accept; drop it or add the prop. |

## Install one into a project

1. **Pick the file** from the table (or list `components/`). Read it fully.
2. **Check the project** supports shadcn structure, Tailwind CSS and TypeScript. If not, tell lyopz and offer setup: `npx shadcn@latest init` (sets up Tailwind + `components/ui` + the `@/` alias).
3. **Find the components folder** (usually `components/ui`, from `components.json`). If it's different, explain why `components/ui` matters (shadcn and every 21st.dev import expect `@/components/ui/...`) and create it.
4. **Copy the component** into `components/ui/<name>.tsx`. Keep the demo only if lyopz wants a test page.
5. **Install what it imports** (e.g. `lucide-react`, `framer-motion`) with the project's package manager.
6. **Fix obvious issues** before using it (missing children/props in the demo, typing gaps), using the smallest change.
7. **Use it** where lyopz asked. For images use real Unsplash URLs; for icons use `lucide-react`.
8. Tell him the file path and one line on how to use it.

## Adding a new component

When lyopz pastes a new 21st.dev prompt: save it as `components/<component-name>.md`, add a row to the table above, commit and push to the degen-skill repo. Don't change the component code when saving it.
