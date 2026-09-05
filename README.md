# Vanilla Shader Collection
This is where I put all my vanilla Minecraft shaders to keep them in one place!

When using any of these, note that any core shaders may be **incompatible** with **sodium** or **modded shaders**.

Only entity core shaders work on sodium. Post shaders are expected to be compatible with most mods.

## Core Minimap
Version: 1.17

Adds a survival minimap with no prior setup.

## Post Raytracing Template
Version: 1.21.10

A setup for raytracing inside a post effect.

To actually use it, you have to spawn an item display entity with the `raytracing:anchor` item model, like this:
`/summon item_display ~ ~ ~ {item:{id:"stick",components:{item_model:"raytracing:anchor"}}} `


## Tentacles posteffect
Version: 26.3

The shader that I made [this tutorial](<https://youtu.be/MDgljYQAD44>) on.

## Stars
Version: 1.21.10

Adds display entities that look like stars. To spawn them, use one of these commands:
`/summon item_display ~ ~ ~ {item:{id:"stick",components:{item_model:"sun"}}}`
`/summon item_display ~ ~ ~ {item:{id:"stick",components:{item_model:"white_dwarf"}}}`

## Triangles
Version: 26.3

Turns all blocks into triangular prisms, made for a tutorial (coming soon). I didn't do anything to fix entities not being synced with the blocks.

## Hexagons
Version: 1.19.2

Turns all blocks into hexagonal prisms. Is a bit more polished than the triangle version, and also works better because hexagons are more similar to cubes than triangles are.

