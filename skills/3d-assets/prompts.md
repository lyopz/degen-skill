# Prompt & design library

Every prompt or design style that worked (or didn't), newest at top. Add to this whenever lyopz shares or approves a prompt, a look, or a design for images, video, 3D or sites. Keep each entry short: what it was for, the prompt/settings, model, cost, result notes.

## 3D source pictures (for image-to-3D)
- **Robot chicken** — see `examples/robot-chicken.md`. Template that worked:
  `A single full-body [THING], [style], [materials/colors], three-quarter view, whole object fully visible, centered, plain neutral grey background, soft even lighting, no text` · `gpt_image_2_5` 1:1.

## Site art (Degen Skills site/app, black + red)
- **Hero** — `recraft_v4_1` 16:9, colors #0b0b0d #e11d2e #ff4d5e #f5f5f7: "Abstract dark cinematic artwork: a glowing red neural network of fine light filaments forming a brain-like constellation, floating over deep black, volumetric red haze, sharp highlights, high contrast, no text".
- **Swarm** — `recraft_v4_1` 4:3: "Abstract dark artwork: a swarm of tiny glowing red orbs moving in formation around a central bright core, motion trails, black background, cinematic, no text".
- **Cards** — `recraft_v4_1` 4:3: "Abstract dark artwork: layered translucent glass panels with glowing red edges stacked in perspective, like UI cards floating in black space, soft red bloom, no text".

## Video (image-to-video)
- **Hero loop** — `seedance_2_5`, 5 s, 16:9, start image = hero: "Seamless slow loop: the glowing red neural constellation slowly rotates and pulses with light traveling along the filaments, red smoke drifts gently below, camera static, cinematic, no text". 35 credits. Made seamless by playing it forward then reversed (ffmpeg `reverse` + `concat`).

## App icon
- Red "matrix" falling code on near-black, rounded square, red border (made with Pillow, no credits).
