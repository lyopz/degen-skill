# Roblox UI — sizes, layout, buttons, feedback (2026)

## Sizes (design at 1920×1080, but build with Scale)
| Thing | Rule |
|---|---|
| Layout | `UDim2` **Scale** for panels, columns, HUD zones; **Offset** only for borders, strokes, gaps, padding, icon squares. Don't mix Scale + Offset on one axis unless a constraint pins it. |
| Min touch target | **44 px** shortest side (Android 48 dp). Important/destructive buttons **56 px**. |
| Gap between tap targets | **≥ 8 px** (44 px buttons with no gap still mis-tap). |
| Main action button (phone) | ~**0.12–0.18** of screen width, square-ish, bottom-right thumb zone; Sprint/Jump/Attack cluster near the default jump button. |
| HUD side buttons (shop, inventory, pets) | Vertical stack on left edge, each ~**0.06–0.08** screen height with `UIAspectRatioConstraint` 1:1, icon + short label. |
| Body text | ≥ **14 px** effective (real screen px, after every UIScale; see "Text under a UIScale" below). Titles 28–48. Use bold, high-contrast fonts (Gotham/Builder Sans/Fredoka One style for fun games). |
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

Use `TweenService` (a debounce stops overlapping clicks). Animate a `UIScale` child, not `Size` (keeps layout stable). Script: `roblox-templates/templates/ButtonFeel.lua`.

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
- **(2026-10-25)** Hold-to-confirm button: start on `MouseButton1Down` (+ ButtonA while `GuiService.SelectedObject == button`), cancel on Up / MouseLeave / SelectionLost / global InputEnded, tween a Fill frame for HOLD_TIME, confirm only if the same hold token is still active; mark it Silent for ButtonFeel.
- **(2026-10-25)** Short landscape phone (799×339): 2-column panels need a compact mode (hide description lines, fold small labels into the title) or the main button falls off; check portrait numerically (button inside viewport, ≥ 44 px) — the zoomed emulator only shows the top. New menus in a big legacy UI: build them as CanvasGroups inside the existing Menus root BEFORE it registers panels, so they inherit backdrop, one-at-a-time, B=back, gamepad selection and ButtonFeel.
- Two SurfaceGuis on the same face of one part fight for draw order (blank sign) → put text on its own transparent plate 0.05 in front.
- In-world labels: SurfaceGui on the Top of a tilted part renders sideways — use a thin plate whose Front faces the player. Picture signs: ImageLabel in a SurfaceGui (LightInfluence 0) + dark backing plate = unlit neon look.

- **(promoted 2026-10-28)** Never put a UIGradient directly on a CanvasGroup (it tints the whole flattened group) — fill + gradient on a child `Bg` frame, CanvasGroup background transparent.
- **(promoted 2026-10-28)** Hiding the HUD for a mode: slide each child off-screen (save its Position) or tween a named UIScale to 0 then `Visible=false`; restore with Back easing. Toggling Visible loses to self-toggling widgets and relayout code.
- **(promoted 2026-10-28)** Per-station chips beside default ProximityPrompts: client listens to `ProximityPromptService.PromptShown` + `prompt.PromptHidden` and hangs one BillboardGui per prompt parent — no server change, new stations get it from config.
- **(promoted 2026-10-28)** Item reward cards: the item ALONE in its own ViewportFrame (camera on the bounds of parts with Transparency < 0.95, 3/4 dir (0.42, 0.28, −1), FOV 30), never mounted on a pet (players read the pet's stats as the item's); VFX-only items → draw an emblem. One results entry that routes by row shape (lazy require) and one owner per card screen.
- **(promoted 2026-10-28)** Phone check without a device: in the Play client clone the HUD into an 844×390 frame with 47 px side insets, apply the controller's scale formula and read AbsoluteSize of text and buttons.

## From projects (2026-11-03)
**Text under a UIScale**
- Effective scale = root UIScale × every panel fit UIScale up the chain. `TextBounds`/`AbsoluteSize` are already real px (never multiply them by the scale again; divide by the scale product before reusing them as offsets).
- UITextSizeConstraint Min/Max measured in design px (a 14 floor at 0.69 drew 9.7 px; one older run said real px, so verify). After each layout set Min/Max (or a fixed TextSize) to `ceil(14 / scale)` (~21 at 0.69), keep the originals in attributes so big screens restore; re-apply when the scale moves > 3%. Check `TextBounds` + `TextFits` live, not the design math.
- TextScaled under a UIScale < 1 fits ONE line only ("LUCK CRYSTAL" → "LUCK") and clips line 2 when the label is shorter than 2 × MinTextSize: for 2-line names use TextScaled false + fixed TextSize + explicit breaks and a box sized to the font's line height (Luckiest Guy ~1.36 em). Word wrap can silently drop the last word.
- TextScaled + AutomaticSize X never shrinks (grows past its box): AutomaticSize None on value labels. Template AutomaticSize / UITextSizeConstraint can override toast sizing: measure text (`TextService:GetTextSize`), bound the width, size pills/bursts from the text (burst = text width / 0.72), grow fixed pills by the measured delta, remeasure after any font switch.
- Max rendered text is 100 px (even under UIScale 2): big title slams animate position (drop-in) + squash, not UIScale. A UIStroke on fading text fades with it, or a dark ghost outline stays.
- Glyph traps: U+2726 is an empty box in GothamBlack (use an image); LuckiestGuy "x0" reads "XO" (hide zero pills); badges `TextWrapped = false`. A narrow column at the 14 px floor turns 4-across strips into 2×2 grids; half-width buttons hide icons and use an uneven split (46/54).

**Scale, fit, look**
- One shared Fit clamp for every screen (0.69–3.0), not per-screen caps (caps of 1.15–1.35 + flat Frame+UIStroke panels + 14 px text made a UI "look 1K" on big screens): 4× 9-slice frame art and a ~21 design-px text floor. Big legacy UI: one Components kit (Panel/Button/Tab/Card/Pill/PriceTag/Countdown/Toast) + a Restyle pass over old panels unifies it without a rebuild.
- Reserving space across two ScreenGuis with different UIScales: publish absolute px (gui attributes like `WalletTopY`) and convert on the reader side. Two ScreenGuis whose Absolute coords must agree use the same ScreenInsets.
- Choose compact/short-screen modes from a size the mode doesn't change (card height / UIScale), not the grid height, or it flips back and forth. lyopz: landscape phone = the PC layout (one rule set); on short phones show one full row + a ~40 px peek of the next instead of shrinking cards.

**Grids and lists**
- Columns from the list's INNER width: subtract the ScrollingFrame UIPadding (L+R) and the scroll bar before dividing, or UIGridLayout fits one fewer column than computed (or read AbsoluteWindowSize after layout). Pick the cell height first (rows that must fit), `cols = round(avail / (cellH*aspect + gap))` within an aspect range (0.8–1.08), then stretch cells to fill the row exactly. No UIAspectRatioConstraint under a UIGridLayout (shrinks cells, keeps the column count, leaves a dead strip).
- More cards per row without rebuilding: design-size card inside a cell frame + UIScale, clamped so the buy bar stays ≥ 44 px real (mouse may use 36). Landscape tab rail: when tabH × scale < 44, swap the UIListLayout for a 2-column grid of `ceil(44/scale)` cells with short labels.
- `UIListLayout.Wraps` in a fixed-height row spills onto what's below: AutomaticSize Y on the row.
- Card kits: give the count/NEW chip ONE fixed slot (e.g. bottom-right of the art well), never collision-measured. A top tier (Secret) is a different class (rotating holo UIGradient border, brackets, crest) driven by one 30 Hz Heartbeat, frozen when the panel is closed; pass the tier as its own field, not parsed from a rarity string. Rarity colour tables need alias normalising + a fallback (Mythic vs Mythical crashed a reel).
- Entrance UIScale tweens go on the card face, not the button (ButtonFeel owns its UIScale). A HUD button cloned from another keeps its `Feel` attribute and ButtonFeel skips it: clear it before Apply.

**Gradients, glows, CanvasGroups**
- A UIGradient MULTIPLIES BackgroundColor3: fill WHITE and put every colour in the gradient (a gradient on a dark fill renders near black). A white sheen frame keeps its own BackgroundTransparency (other code can disable gradients → solid white card).
- CanvasGroups clip everything inside, outer UIStrokes too: breakout strokes/rays/glows go on the parent host; a dim layer belongs on the ScreenGui root; inset a card's Bg by the stroke margin (~8 px) in a transparent holder. CanvasGroup + UICorner(0.5) clips a scrolling texture to a circle (works in SurfaceGuis too). Rotated GuiObjects don't clip children (radial arcs = two unrotated ClipsDescendants halves).
- Round glows: UIAspectRatioConstraint (ScaleWithParentSize, DominantAxis Width) or a Scale glow stretches to an ellipse; stacked-circle glows on dark wells need ~16 layers with graded alpha (outer ~1%). A rarity glow does nothing on grey Common cards: core glow in the item's own hue.
- Art-free "pill" buttons: UICorner(0.5) + gradient body + UIStroke with its own rotating UIGradient + inset lip; only raster = a white 9-slice halo behind (`SliceScale = H/coreHeightPx`) in a transparent Slot (a child can't draw behind its parent). A glint band on a pale face needs a white UIStroke (Contextual) so it shows on a still frame. Full-screen edge flash: inset the frame by half the stroke (half draws off screen).

**ViewportFrame cards**
- Fit the camera to the model's bounding box: project the 8 corners through the camera (vertical FOV AND the frame aspect) and pull in to ~0.86–0.88 fill; refit on AbsoluteSize change. A bounding-sphere or fixed distance leaves the model at ~40% / cropped.
- No particles: auras = captured flipbooks (ImageRectOffset stepped by ONE shared strong-keyed Heartbeat, frozen when hidden, cell px ≥ on-screen size; crossfading 2 stacked frames makes 8 fps smooth) or a few Neon part stand-ins; 3D-item fire/sparks around it = 2D UI.
- Looks: rim light = a flat Neon clone in a 1–2% bigger VF behind, offset 3 px, 45% transparent, pivoted with the model; soften a busy ColorMap with a SmoothPlastic shell (×1.006, ~0.55 transparent); never use scaled copies of hollow/one-sided meshes as outlines (they draw in front). Decals/face parts do render (strip them for bare-body previews). Apply runtime overlays to the clone inside the VF, never the cached template.

**Prompts, world-anchored UI, input**
- Custom ProximityPrompt UI: create the prompt on the CLIENT (Style Custom), drive a ScreenGui from PromptShown/PromptHidden (filter by `prompt.Name`), bind extra keys with ContextActionService only while shown, and locally disable other prompts under that model. Anchor on a static Attachment (e.g. under `workspace.Terrain`) on the model's axis, never from a spinning model's pivot. Prompts only show with the anchor in camera view.
- One key map for all in-world prompts and ONE script per key: two CAS binds on one key at the same priority = the later wins silently. Several prompt plates on one part: stack per UIOffset.X column sorted by UIOffset.Y, each at max(own offset, previous + height + gap).
- Screen-anchoring to 3D: WorldToViewportPoint is full-viewport px, AbsolutePosition is viewport minus `GuiService:GetGuiInset()`; child offset = (vp − inset) − gui.AbsolutePosition. Billboard titles with TextScaled: width by character count (`clamp(#text*0.52, 5, 13)` studs, height 1.5) so every name has the same letter height. SurfaceGui text: `LightInfluence 0`, CanvasSize ~140 px/stud; on a pale gold plate use a dark inset.
- Gamepad selection: gate it on `GetLastInputType()` being Gamepad*, never `GamepadEnabled` (Studio reports true with no pad → cyan box for mouse players); one client guard clears SelectedObject on mouse/touch input. SelectionImageObject ignores AnchorPoint: ring = Position (−5,−5) offset, Size (1,10,1,10). Only select Selectable + Visible objects under an enabled PlayerGui ScreenGui. Escape never reaches CAS: close on ButtonB/Backspace + `UserInputService.InputBegan` Escape regardless of gameProcessed.

**HUD, toasts, notices**
- `DeviceSafeInsets` ignores IgnoreGuiInset (a toast lands under the top bar): HUD toasts and full-screen shops use `CoreUISafeInsets`. A top-centre toast lane measures the HUD button boxes at runtime and centres in the free band, shrinking (to ~0.5) before ever dropping under them. Two-line toasts ≤ ~30 characters.
- One event = one notice owner (two notices = two systems own it) and one clock: every timer for the same thing reads the same EndsAt at the same tick rate. Hover-opened popups check the menu-open state too.
- Runtime HUD fade without touching modules: record every Background/Text/TextStroke/Image transparency + UIStroke.Transparency, tween to 1, restore the recorded values; ref-count by caller key with a watchdog.
- Sound: one game SoundGroup driven by the saved volume (every UI/reveal Sound routes to it) = one-line mute. Sliders: ~64 px invisible hit area around an 18 px bar, non-Selectable (gamepad uses −/+), half a knob of gap from the buttons.

**More (2026-11-03)**
- Phone root UIScale (~0.6–0.7) shrinks offset buttons under 44 px → grow them to `ceil(46/k)`. Judge phone shots at real device scale (shrinking the root fakes truncation); a `DebugViewport` Vector2 attribute that lays the root out as a phone box gives portrait shots without the emulator.
- One-line labels: TextScaled + TextWrapped=false + TextTruncate AtEnd, short words (phone 14 px floor; square boxes wrap "VS"). World labels: size in offset + nearest-first screen declutter.
- Sheen/decor child frames break UIListLayout containers; per-mode layout tables need every key in every mode. Cap card columns to the item count; derive card art from Id/Name when client rows lack server fields. ViewportFrame spinners check the whole ancestor chain is visible.
- ZIndexBehavior Sibling: a raised card paints all its descendants (glow, rays) over neighbours → put the glowing card BELOW its siblings so its halo stays behind. `rbxasset` RadialFill.png is a hard ring (reads as a target): soft glow = ~5 circle Frames (BackgroundTransparency 0.82, sizes 1..0.28) in one CanvasGroup.
- Shaped buttons: draw the layers as SVG, render with headless Edge `--default-background-color=00000000 --screenshot` at 2× (no `--remote-debugging-port`, or it never exits), upload, stack ImageLabels + TextLabels (the same SVGs drive the mockup). Cancel a running tween before setting the same property instantly.

## From projects (2026-11-05)
**Scale + screen space**
- Build the HUD in DESIGN px under one root UIScale from the shared Fit clamp (0.69–3.0); dividing sizes by the root scale brings back the "1K" look. Size tap targets for the SMALLEST fit (phone menu fit ~0.6 → 76 design px = 45 real); phone menus must end above the thumbstick (~300 screen px at Fit 0.69): shrink icons, never the tap rows. Stacked small rows: an invisible 64×64 hit on the key button, neighbours' hits shifted apart.
- `UITextSizeConstraint` clamps REAL px: in a panel scaled to ~0.5, MinTextSize 16 = 30 design px → TextScaled overflows and clips words. Keep MinTextSize ~8 in UIScale-fitted panels, `TextWrapped=false` on one-liners, check readability at the smallest fit. (Older note in "Text under a UIScale" said design px — this run measured real px.)
- Top-bar line: a ScreenGui with `ScreenInsets = TopbarSafeInsets` covers `GuiService.TopbarInset` (between Roblox's buttons); scale content to the bar height and fall back when the area is < 120×30. Centre on the SCREEN centre with `x = screenCx − bar.AbsolutePosition.X`, `width = 2·min(x, barW − x)`. `DeviceSafeInsets` ignores `IgnoreGuiInset=false` (Root starts at y = −58): measure Root.AbsolutePosition before placing "under the top bar".
- Tap-outside-to-close: `InputObject.Position` and `AbsolutePosition` share one space — compare directly (adding GuiInset makes taps on the panel's bottom count as outside). Close only on a quick tap (< 0.35 s, < 14 px). A full-screen dim overhangs every side (Position −100, Size +200) or insets leave a dead strip.
- Sharing positions between scripts: publish edges as screen-px attributes on a shared ScreenGui/PlayerGui (0 when hidden). A frame popping with a UIScale reports a moving AbsolutePosition → keep an invisible unscaled "probe" twin and publish the probe's position.
- Drawing above other ScreenGuis: move the pieces into their own ScreenGui with a higher DisplayOrder, mirror the HUD rect on every change, hide it whenever the HUD hides.
**Layout + look**
- `UIGridLayout` HorizontalAlignment Center centres the whole block, not a short last row: place tiles by hand (`x0 = (W − (n·TILE + (n−1)·GAP))/2` per row). Sliding centred rows: no UIListLayout, `x = (i − (n+1)/2)·step`, tween to the new slot, new items appear at their final slot. 4→3 columns: keep the cluster width, grow tiles, shrink the row gap.
- Even see-through hexagon/polygon = one CanvasGroup with 3 opaque bars rotated 0/60/120 + GroupTransparency (separate transparent bars double up); rim = 6 rotated edge frames. Radial timers = two clipped half-rings + UIStroke UIGradient (no image). Glass shimmer = white face × UIGradient band at 0.5, Rotation 25, Offset tweened −1→1 on repeat; skip on `ReducedMotionEnabled`. A glass button's glow is a SIBLING behind it (ZIndex − 1), never a child. Card-less tile labels ≤ tile + gap wide.
- Hiding the button that opened a panel: a second UIScale "Tuck" (ButtonFeel owns "FeelScale") tween 1→0 + `Interactable=false`; never toggle Visible inside a layout (relayouts neighbours). Zone-gated HUD buttons: client-only gate (attributes + a 0.25 s HRP-in-box check, box cached 2 s for streaming); pop with UIScale Back Out 0.22 / Back In 0.14.
- ViewportFrames inside a ScrollingFrame still render off-screen: cull to visible tiles (re-check on CanvasPosition/AbsoluteSize, `task.defer` to coalesce); destroy Textures on faces turned away from the VF camera; a still card needs no WorldModel. Exact framing: project every part's 8 corners through the real camera for the current pitch only, cache per 0.05 rad.
- TextBox Text-changed handlers run deferred: a test hook that sets `.Text` must set the filter state itself. Currency rename: also grep baked UI-builder text, live StarterGui labels and icon maps for OLD asset ids (aliases kept old art).
- Shots at a target size inside a small Studio window: resize the HUD root to the target DESIGN size (or multiply root Scale by k: PC 1920×1080 0.428, phone 844×390 0.974, portrait 0.713), relayout, crop, restore after; popups in their own ScreenGui need their holder moved to the faked HUD rect.
- lyopz's HUD taste: no cards behind HUD icons/currencies; coins + XP small, grouped right above the menu buttons in one top-left cluster; PC and phone show the same buttons.

## Performance
- Disable the whole `ScreenGui` instead of toggling many `.Visible`.
- Fade groups with one `CanvasGroup.GroupTransparency` tween.
- Pool ~20 frames for scrolling lists; size `CanvasSize` from item count (`AutomaticCanvasSize`).
- Update labels on change or every 0.1 s, never every frame. HUD cost: a couple of ms/frame on the lowest device.
- Test: smallest portrait phone, tablet landscape, 21:9 ultrawide, console — with Studio's Device Simulator toolbar (out of beta Oct 2026: mouse-wheel device switching, network simulator for lag). https://devforum.roblox.com/t/weekly-recap-october-12-18-2026/4938638
