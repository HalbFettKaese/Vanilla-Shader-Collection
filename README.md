# Vanilla Shader Collection
When using any of these, note that any core shaders may be **incompatible** with **sodium** or **modded shaders**.

Only entity core shaders work on sodium. Post shaders are expected to be compatible with most mods.

To download the individual packs, look over to the [Releases](<https://github.com/HalbFettKaese/Vanilla-Shader-Collection/releases>) section.
## Core Minimap
Version: 1.17

Adds a survival minimap with no prior setup needed.

https://github.com/user-attachments/assets/59c53fd4-9f93-4034-8d94-23baca7c9534

## Post Raytracing Template
Version: 1.21.10

A setup for raytracing inside a post effect.

To actually use it, you have to spawn an item display entity with the `raytracing:anchor` item model, like this:
`/summon item_display ~ ~ ~ {item:{id:"stick",components:{item_model:"raytracing:anchor"}}} `

https://github.com/user-attachments/assets/b295bfe2-65e2-4135-ae03-e3bc40410e4a

## Tentacles posteffect
Version: 26.3

The shader that I made [this tutorial](<https://youtu.be/MDgljYQAD44>) on.

## Stars


Version: 1.21.10

Adds display entities that look like stars. To spawn them, use one of these commands:
`/summon item_display ~ ~ ~ {item:{id:"stick",components:{item_model:"sun"}}}`
`/summon item_display ~ ~ ~ {item:{id:"stick",components:{item_model:"white_dwarf"}}}`

https://github.com/user-attachments/assets/158fab51-d2e9-4061-a613-73a63ecca640

## Triangles
Version: 26.3

Turns all blocks into triangular prisms, made for a tutorial (coming soon). I didn't do anything to fix entities not being synced with the blocks.

<img width="1920" height="1017" alt="triangles" src="https://github.com/user-attachments/assets/4417c061-8c27-4701-8163-219843eab695" />


## Hexagons
Version: 1.19.2

Turns all blocks into hexagonal prisms. Is a bit more polished than the triangle version, and also works better because hexagons are more similar to cubes than triangles are.

<img width="1920" height="1080" alt="hexagons" src="https://github.com/user-attachments/assets/d993eb37-d6ac-4106-a89c-fdd8ec96d670" />

