#version 330
#extension GL_ARB_separate_shader_objects : require

//#define PIXELATED

#include <minecraft:fog.glsl>
#include <minecraft:globals.glsl>
#include <minecraft:texture_sampling.glsl>
#include <minecraft:oit.glsl>
#include <minecraft:terrainglobals.glsl>
#ifndef MULTIDRAW_TERRAIN
    #include <minecraft:chunksection.glsl>
#endif

uniform sampler2D Sampler0;

#include <minecraft:ichor.glsl>

layout(location = 0) in float sphericalVertexDistance;
layout(location = 1) in float cylindricalVertexDistance;
layout(location = 2) in vec4 vertexColor;
layout(location = 3) in vec2 texCoord0;
layout(location = 4) in float chunkVisibility;
layout(location = 5) in vec3 globalPos;
layout(location = 6) in vec3 forward;
layout(location = 7) in vec4 vertex0;
layout(location = 8) in vec4 vertex1;
layout(location = 9) in vec4 vertex2;
layout(location = 10) in vec4 vertex3;
layout(location = 12) in vec3 uv0;
layout(location = 13) in vec3 uv1;
layout(location = 14) in vec3 uv2;
layout(location = 15) in vec3 uv3;

#ifndef OIT_ALPHA_ONLY
layout(location = 11) in vec4 lightmapColor;
layout(location = 0) out vec4 fragColor;
#endif

vec4 calculateFinalColor(vec4 color) {
    #ifdef OIT_ACCUMULATE
    color = sampleColorForAccumulation(color);
    vec4 fogColor = vec4(FogColor.rgb * color.a, FogColor.a);
    #else
    vec4 fogColor = FogColor;
    #endif
    return apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, fogColor);
}

vec4 posToUv() {
    vec3 p0, p1, p2;
    vec4 ws = abs(vec4(vertex0.w, vertex1.w, vertex2.w, vertex3.w));
    ws -= min(min(ws.x, ws.y), min(ws.z, ws.w));
    vec2 u0, u1, u2;
    if (ws.x == 0.0) {
        p0 = vertex1.xyz / vertex1.w;
        p1 = vertex2.xyz / vertex2.w;
        p2 = vertex3.xyz / vertex3.w;
        u0 = uv1.xy / uv1.z;
        u1 = uv2.xy / uv2.z;
        u2 = uv3.xy / uv3.z;
    } else if (ws.y == 0.0) {
        p0 = vertex0.xyz / vertex0.w;
        p1 = vertex2.xyz / vertex2.w;
        p2 = vertex3.xyz / vertex3.w;
        u0 = uv0.xy / uv0.z;
        u1 = uv2.xy / uv2.z;
        u2 = uv3.xy / uv3.z;
    } else if (ws.z == 0.0) {
        p0 = vertex0.xyz / vertex0.w;
        p1 = vertex1.xyz / vertex1.w;
        p2 = vertex3.xyz / vertex3.w;
        u0 = uv0.xy / uv0.z;
        u1 = uv1.xy / uv1.z;
        u2 = uv3.xy / uv3.z;
    } else {
        p0 = vertex0.xyz / vertex0.w;
        p1 = vertex1.xyz / vertex1.w;
        p2 = vertex2.xyz / vertex2.w;
        u0 = uv0.xy / uv0.z;
        u1 = uv1.xy / uv1.z;
        u2 = uv2.xy / uv2.z;
    }
    minCoord = min(u0, min(u1, u2));
    maxCoord = max(u0, max(u1, u2));
    vec3 normal = abs(cross(p2-p0, p1-p0));
    vec3 dir = normalize(forward);
    vec3 pos1 = globalPos;
    #ifndef PIXELATED
        pos1 += dir * 0.1;
    #endif
    vec3 pos2 = globalPos + dir;
    if (normal.y > normal.x && normal.y > normal.z) {
        return vec4(pos1.xz, pos2.xz + 0.1 * dir.xz / abs(dir.y));
    } else if (normal.x > normal.z) {
        return vec4(pos1.zy, pos2.zy + 0.1 * dir.zy / abs(dir.x));
    } else {
        return vec4(pos1.xy, pos2.xy + 0.1 * dir.xy / abs(dir.z));
    }
}

void main() {
    vec2 atlasSize = vec2(textureSize(Sampler0, 0));
    float alpha = round(texelFetch(Sampler0, ivec2(texCoord0 * atlasSize), 0).a * 255.);
    vec4 color;
    if (alpha == 254.0) {
        vec4 uv = posToUv();
        #ifdef PIXELATED
            uv = floor(uv * 16.) / 16.;
        #endif
        color = vec4(water(uv.xy, uv.zw, GameTime * 1200.0), 1.);
    #ifndef OIT_ALPHA_ONLY
        color *= lightmapColor;
    #endif
    } else {
        color = (UseRgss == 1 ? sampleRGSS(Sampler0, texCoord0, 1.0f / TextureSize) : sampleNearest(Sampler0, texCoord0, 1.0f / TextureSize)) * vertexColor;
    }
    #ifndef OIT_ALPHA_ONLY
    color = mix(FogColor * vec4(1, 1, 1, color.a), color, chunkVisibility);
    #endif
    #ifdef ALPHA_CUTOUT
    if (color.a < ALPHA_CUTOUT) {
        discard;
    }
    #endif

    #ifdef OIT_ALPHA_ONLY
    executeAlphaOnlyPhase(gl_FragCoord.z, color.a);
    #else
    fragColor = calculateFinalColor(color);
    #endif
}
