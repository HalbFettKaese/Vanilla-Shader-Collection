#version 330
#extension GL_ARB_separate_shader_objects : require

#include <minecraft:fog.glsl>
#include <minecraft:globals.glsl>
#include <minecraft:projection.glsl>
#include <minecraft:sample_lightmap.glsl>
#include <minecraft:terrainglobals.glsl>
#ifndef MULTIDRAW_TERRAIN
    #include <minecraft:chunksection.glsl>
#endif

layout(location = 0) in vec3 Position;
layout(location = 1) in vec4 Color;
layout(location = 2) in vec2 UV0;
layout(location = 3) in ivec2 UV2;
#ifdef MULTIDRAW_TERRAIN
layout(location = 4) in ivec3 ChunkPosition;
layout(location = 5) in float ChunkVisibility;
#endif

#ifndef OIT_ALPHA_ONLY
layout(location = 11) out vec4 lightmapColor;
uniform sampler2D Sampler2;
#endif

layout(location = 0) out float sphericalVertexDistance;
layout(location = 1) out float cylindricalVertexDistance;
layout(location = 2) out vec4 vertexColor;
layout(location = 3) out vec2 texCoord0;
layout(location = 4) out float chunkVisibility;
layout(location = 5) out vec3 globalPos;
layout(location = 6) out vec3 forward;
layout(location = 7) out vec4 vertex0;
layout(location = 8) out vec4 vertex1;
layout(location = 9) out vec4 vertex2;
layout(location = 10) out vec4 vertex3;

void main() {
    vertex0 = vertex1 = vertex2 = vertex3 = vec4(0);
    switch (gl_VertexIndex % 4) {
        case 0: vertex0 = vec4(Position, 1); break;
        case 1: vertex1 = vec4(Position, 1); break;
        case 2: vertex2 = vec4(Position, 1); break;
        case 3: vertex3 = vec4(Position, 1); break;
    }
    globalPos = Position + ChunkPosition;
    vec3 pos = Position + (ChunkPosition - CameraBlockPos) + CameraOffset;
    forward = pos;
    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);

    sphericalVertexDistance = fog_spherical_distance(pos);
    cylindricalVertexDistance = fog_cylindrical_distance(pos);
    #ifndef OIT_ALPHA_ONLY
    lightmapColor = sample_lightmap(Sampler2, UV2);
    vertexColor = Color * lightmapColor;
    #else
    vertexColor = Color;
    #endif
    texCoord0 = UV0;

    const float chunkFullyVisibleRange = 16.0;
    float dist = length(pos);
    chunkVisibility = mix(1.0, ChunkVisibility, clamp((dist - chunkFullyVisibleRange) / chunkFullyVisibleRange, 0.0, 1.0));
}
