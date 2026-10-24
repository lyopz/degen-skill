# Roblox UI — sizes, layout, buttons, feedback (2026)

## Sizes (design at 1920×1080, but build with Scale)
| Thing | Rule |
|---|---|
| Layout | `UDim2` **Scale** for panels, columns, HUD zones; **Offset** only for borders, strokes, gaps, padding, icon squares. Don't mix Scale + Offset on one axis unless a constraint pins it. |
| Min touch target | **44 px** shortest side (Android 48 dp). Important/destructive buttons **56 px**. |
| Gap between tap targets | **≥ 8 px** (44 px buttons with no gap still mis-tap). |
| Main action button (phone) | ~**0.12–0.18** of screen width, square-ish, bottom-right thumb zone; Sprint/Jump/Attack cluster near the default jump button. |
| HUD side buttons (shop, inventory, pets) | Vertical stack on left edge, each ~**0.06–0.08** screen height with `UIAspectRatioConstraint` 1:1, icon + short label. |
| Body text | ≥ **14 px** effective; `TextScaled` + `UITextSizeConstraint` MinTextSize **14** (MaxTextSize so it doesn't balloon on PC). Titles 28–48. Use bold, high-contrast fonts (Gotham/Builder Sans/Fredoka One style for fun games). |
| Corner radius | One value everywhere: **8–16 px** (`UICorner`). |
| Shadows | `UIShadow` (live 2026) instead of a fake dark frame. Beta (2026-10, can't publish yet): `Mode = Text` text shadows, `Inset` recessed look, `ShowBehindParent = false` knockout for see-through panels, child `UIGradient` for colored glow. Keep < 100 on screen. https://devforum.roblox.com/t/studio-beta-upgraded-uishadow-capabilities/4934553 |
| Panel padding | **12–24 px** (`UIPadding`), list gap **8 px** (`UIListLayout.Padding = UDim.new(0, 8)`). |
| Example panel | 60% width × 70% height (Scale) + `UISizeConstraint` min 320×400 px, max ~900×700 for ultrawide. |
| Grid slots | 96×96 px cells, 8 px padding; `UIAspectRatioConstraint` 1 on every slot. |
| Icons | Author at **2×** display size (64 px slot → 128 px image). |
| Dividers/strokes | 1–2 px Offset (Scale strokes balloon to 3 px on 4K). `UIStroke` 2–3 px on buttons for the cartoon look. |
| Top bar | Roblox top bar ~**36 px** (more on notched phones): keep the top ~40 px clear. |
| Safe area | Interactive layers `ScreenInsets = DeviceSafeInsets`; full-bleed backgrounds `None`. Keep critical text out of the outer 5% per side; +5–8% inset for corner-pinned buttons. |

Layout tools: `UIListLayout`, `UIGridLayout`, `UIPadding`, `UIAspectRatioConstraint` (anything whose shape matters: slots, portraits, minimap, ability icons), `UISizeConstraint` (cap scale panels), `UIScale` (global UI size slider / per-device scaling). Recompute on `Camera:GetPropertyChangedSignal("ViewportSize")`.

## Input
- Branch on `UserInputService.LastInputType` (update on `LastInputTypeChanged`), not `TouchEnabled` — players switch input mid-session.
- Hover states are mouse-only; touch gets press states.
- **Gamepad:** set `GuiService.SelectedObject` to a default button when a screen opens (nil on close), every interactive element `Selectable`, explicit `NextSelection*` on non-grid layouts, `SelectionGroup` on modals, custom `SelectionImageObject` readable from a couch, B = back via `ContextActionService`, release focus on `GuiService.MenuOpened`, restore on close, remember last selected per screen.

## Feel (every button)
| Moment | Effect | Timing |
|---|---|---|
| Hover (mouse) / Select (gamepad) | scale **1.06**, stroke/glow brighter, tiny rotate 2–3° for playful games, soft tick sound | 0.12 s Quad Out |
| Press | scale **0.92**, darken 10% | 0.06 s Quad Out |
| Release / click | back to 1.0 with **Back Out** overshoot, click sound, optional ripple | 0.18–0.25 s |
| Panel open | from scale 0.85 + transparent → 1 (CanvasGroup GroupTransparency), backdrop dim 0.4 | 0.25–0.35 s Back/Quint Out |
| Panel close | to 0.9 + fade | 0.15–0.2 s Quad In |
| Not allowed (no money) | shake left-right 3× 6 px + red flash + error buzz | 0.25 s |
| Purchase / reward | button pops 1.15, sparkle burst, coins fly from button to currency counter, counter counts up | 0.4–0.8 s |

Use `TweenService` (a debounce stops overlapping clicks). Animate a `UIScale` child, not `Size` (keeps layout stable). Script: `../scripts/ButtonFeel.lua`.

## Sound
- Distinct sounds: hover tick, click, open, close, error, purchase/reward, level-up. Keep UI sounds short (< 0.3 s) and quiet (Volume ~0.3–0.5); randomize pitch ±5% on repeated sounds; raise pitch on streaks/combos.
- Put UI sounds in `SoundService` (or a SoundGroup "UI") so a settings slider can control them.

## HUD layout pattern (simulator/tycoon/fighting)
- Top-center: currency (icon + big number, `+123` popups).
- Left: vertical menu stack (Shop, Pets/Inventory, Rebirth, Codes/Daily, Settings) with notification dots.
- Bottom-right: main action(s) for mobile. Bottom-center: hotbar (fighting/tools).
- Right or top-right: quests/objective tracker, timers for events.
- Modals center with a dim backdrop and a big X (≥ 44 px) top-right.
- **Clicker variant** (seen in Tap Simulator REBORN, lyopz liked): giant square tap button bottom-center with the per-tap amount above it, pets button (count badge) left and auto-tap toggle right; counters stacked bottom-left with a +/s rate; Shop/Trade as big labeled buttons on the left; icon column on the right opening side panels; boosts row + event banner with countdown top-center.
- **Tier shop** (seen in Tap Simulator REBORN, lyopz liked): stepped upgrades as a grid of tall cards, each a different color with its own themed icon and "+N" label, green check when owned; a big detail panel on the right (icon, name, cost, Buy/Owned). Shop title also floats over the in-world machine.
- **Event sign-up**: in-world board (art, date, "Starts in" countdown) with a ProximityPrompt "Sign Up" that opens the native Experience Events Notify Me sheet; small toasts top-left for live world events.

## Gotchas from projects (promoted 2026-10-24)
- Never name a GUI child after a property (`Name`, `Size`, `Position`…): `card.Name.Text` reads the property. Use `Label`.
- Templates inside a ScreenGui: a Folder still renders its GUI children → keep them in a `Visible=false` Frame. Apply ButtonFeel to the live root, never the template holder.
- Global UIScale over Scale UI: size the root at 1/scale (centered), clamp so 64 design-px buttons stay ≥ 44 px. A card inside a panel inherits the panel's open/close UIScale — size from design height (AbsoluteSize / root scale / panel scale).
- ButtonFeel's hover UIScale pushes row-mates in a UIListLayout → leave ~6% spare width per row.
- Short landscape phones (~338 px tall ≈ 405 design px): compact mode — side tiles pinned top, 2×2 icon grid, panels 97% height; a station panel fits as ONE horizontal row (UIGridLayout FillDirection Vertical + FillDirectionMaxCells 1, ScrollingDirection X, AutomaticCanvasSize X).
- Thumbstick: bottom-left counters collide with `PlayerGui.TouchGui.…ThumbstickStart` — read its AbsolutePosition in the rescale and place the stack right/above it; TouchGui appears late → re-layout on `PlayerGui.ChildAdded`.
- Toasts inside the HUD frame render under later-sibling menus → parent toasts to the UI root with higher ZIndex.
- `UIStroke` on TextLabel/TextButton defaults to outlining the TEXT: set `ApplyStrokeMode = Border` for chip/button borders.
- Glow outline without betas: a slightly larger transparent frame with only a UIStroke; brighten on hover.
- Currency/icon sets: give each a different SILHOUETTE, not just a color — same emblem reads as the same icon at 44 px.
- ViewportFrame cards: no particles/beams/lights (decals on transparent parts do render). Undiscovered pets: real model with ImageColor3/Ambient/LightColor black; reveal = black → white flash → light back + Back-bounce UIScale. Fake sparkles with a 2D ImageLabel pool projected from the model's bbox.
- Settings sliders: round with `floor(v*100+0.5)/100`, not `floor(v/0.01+0.5)*0.01` (float noise breaks equality).
- In-world labels: SurfaceGui on the Top of a tilted part renders sideways — use a thin plate whose Front faces the player. Picture signs: ImageLabel in a SurfaceGui (LightInfluence 0) + dark backing plate = unlit neon look.

## Performance
- Disable the whole `ScreenGui` instead of toggling many `.Visible`.
- Fade groups with one `CanvasGroup.GroupTransparency` tween.
- Pool ~20 frames for scrolling lists; size `CanvasSize` from item count (`AutomaticCanvasSize`).
- Update labels on change or every 0.1 s, never every frame. HUD cost: a couple of ms/frame on the lowest device.
- Test: smallest portrait phone, tablet landscape, 21:9 ultrawide, console — with Studio's Device Simulator toolbar (out of beta Oct 2026: mouse-wheel device switching, network simulator for lag). https://devforum.roblox.com/t/weekly-recap-october-12-18-2026/4938638
