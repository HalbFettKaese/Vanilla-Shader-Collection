#version 330

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:globals.glsl>

uniform sampler2D Sampler0;

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec2 texCoord1;

out vec4 fragColor;

in vec3 position;
in vec4 vNearPos;
flat in vec3 center;
flat in vec3 localZ;
flat in int drawType;
flat in vec4 textureBounds;
flat in vec3 starColor1;
flat in vec3 starColor2;
flat in float starRadius;

#define PI 3.14159
mat2 rot2(float angle) {
    return mat2(cos(angle),sin(angle),-sin(angle),cos(angle));
}

vec4 _texture(vec2 uv) {
    return texture(Sampler0, mix(textureBounds.xy, textureBounds.zw, fract(uv)));
}

vec4 drawStar(vec3 ro, vec3 rd, float r, vec3 starColor, vec3 starGlow, out float _t) {
    float time = GameTime * 1200. * .1;
    float a = dot(ro, rd)/dot(rd, rd);
    float b = (dot(ro, ro) - r*r)/dot(rd, rd);
    float D = max(0., a*a - b);
    float t = -a - sqrt(D);
    t = max(0., t);
    vec3 p = ro + t * rd;
    
    float hitSun = smoothstep(0.15 * r * r, 0., dot(p, p) - r*r);
    _t = t;
    
    float corona = smoothstep(1. * r * r, 0., dot(p, p) - r*r);
    
    // Triplanar map
    vec3 w = abs(p);
    w /= dot(w, vec3(1));
    float z = dot(p, -normalize(ro)) / r;
    vec3 planar = p/r + z * normalize(ro);
    float shine = (1.+z)/dot(planar, planar);
    float glow = clamp(1./length(ro)-0.1*length(planar), 0., 1.);
    vec3 sunColor = vec3(0);
    if (corona >= 0.0)
        sunColor = starColor + (
          _texture(p.yz/r + vec2(0.25,-1) * time * sign(p.x)).rgb * w.x +
          _texture(p.xz/r * rot2(2.*time) * sign(p.y)).rgb * w.y +
          _texture(p.xy/r + vec2(1,-0.25) * time * sign(p.z)).rgb * w.z
        );
  vec3 col = 0.8*shine*starColor + (0.7*hitSun + 0.1*corona)*sunColor + glow*starGlow;
  return vec4(max(vec3(0), col), hitSun); // alpha 0: additive blending, alpha 1: default blending
}

vec4 raytrace(vec3 ro, vec3 rd, out float t) {
    return drawStar(ro, rd, starRadius, starColor1, starColor2, t);
}

void setupRaytrace() {
    vec3 nearPos = vNearPos.xyz / vNearPos.w;
    vec3 raydir = normalize(position - nearPos);

    float t;
    vec4 col = raytrace(nearPos - center, raydir, t);
    float a = col.a;
    a = max(a, min(1., max(col.r,max(col.g,col.b))));
    if (a <= 0.0) discard;
    fragColor = vec4(col.rgb / a, a);
}

void main() {
    if (drawType != 0) {
        setupRaytrace();
        return;
    }
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    if (color.a < 0.1) {
        discard;
    }
    fragColor = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
}
