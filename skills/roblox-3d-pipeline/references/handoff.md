# Handoff block (stage 6)

The 3D designer can't start other agents itself. It ends with this block and the Lead sends the next agent straight away, with no question to lyopz.

```
HANDOFF
asset: <name>            studio: <path in the place, e.g. ReplicatedStorage.Pets.FireDragon>
files: <models/asset/export/asset.glb>, <shots/asset_view0.png>, <notes.md>
size: <studs>  tris: <n>  credits: <spent>
rating: <Love it / Like it / Change something / Don't like it / not rated>
next:
  - roblox-animator: <why, e.g. "pet: idle bob + walk; wings flap"> (rig: Custom)
  - roblox-vfx-artist: <e.g. "fire element: flicker on crystal cracks, subtle">
  - roblox-scripter: <e.g. "add to pet table, follow player">
  - roblox-reviewer: always last
not done / needs lyopz: <or "none">
```

Who comes next:
| The asset... | Next agent |
|---|---|
| moves (pet, NPC, creature, door) | roblox-animator |
| has an element, aura, trail, sparkle | roblox-vfx-artist |
| needs behaviour (follow, hatch, buy) | roblox-scripter |
| is a map piece / building / prop to place | roblox-map-builder |
| needs an icon / card / shop image | roblox-ui-designer |
| always, at the end | roblox-reviewer |

When there are several, list them in order. Agents in the same wave can run in parallel, e.g. animator + vfx-artist, then scripter, then reviewer.
