// Port of my shadertoy: https://www.shadertoy.com/view/N3y3Dm

#include <minecraft:oklab.glsl>
#include <minecraft:simplex.glsl>

// My own sift water code
#define TWOPI 6.28318530718

float sharpness = 8.0;
float starBrightness = 3.0;
float densityOffset = 0.2;

vec2 minCoord;
vec2 maxCoord;

float fbm(vec3 uv) {
    float r = 0.0;
    for (float s = 1.0; s <= 64.; s *= 2.) {
        r += simplex3d(uv * s) / pow(s, 1.2);
    }
    return r;
}

vec2 fbm2(vec3 uv) {
    return vec2(fbm(uv), fbm(uv + 50.));
}

float angleDist(vec2 uv, float angle) {
    return distance(uv, vec2(cos(angle), sin(angle)));
}

vec3 clouds(vec2 uv, float t, out vec2 offset) {
    offset = 0.15*fbm2(vec3(uv, t*3.));
    uv += offset;
    vec2 r = fbm2(vec3(uv, t * 10.));
    
    r.x += 0.1;
    vec4 weights = vec4(
        angleDist(r, 0.0),
        angleDist(r, TWOPI*0.25),
        angleDist(r, TWOPI*0.50),
        angleDist(r, TWOPI*0.75)
    );
    weights = exp(weights*-sharpness);
    weights /= dot(weights, vec4(1));
    return mat4x3(
        oklab_from_linear_srgb(linear_srgb_from_srgb(vec3(7, 200, 141)/255.)),
        oklab_from_linear_srgb(linear_srgb_from_srgb(vec3(1, 166, 198)/255.)),
        oklab_from_linear_srgb(linear_srgb_from_srgb(vec3(205, 166, 140)/255.)),
        oklab_from_linear_srgb(linear_srgb_from_srgb(vec3(192, 119, 203)/255.))
    ) * weights;
}

float stars(vec2 uv, float t) {

    t *= 0.3;
    uv *= 8.0;
    vec2 id = floor(uv);
    t += dot(vec2(311.83139, 82.5321), id);
    vec3 r1 = random3(vec3(id, floor(t)));
    vec3 r2 = random3(vec3(id, floor(t)+1.));
    vec3 r = mix(r1, r2, smoothstep(0., 1., fract(t)));
    uv = fract(uv);
    uv -= 0.5 + r.yz * 0.5;
    uv /= 0.25 * mix(0.2,1.,r.x+0.5);
    return smoothstep(0.5, 0., length(uv)) * (r.x + 0.5);
}

float ghost(vec2 uv, float t, float cutoff) {
    t *= 0.3;
    uv *= 8.0;
    vec2 id = floor(uv);
    t += dot(vec2(311.83139, 82.5321), id);
    vec3 r = random3(vec3(id, 0.0));
    uv = fract(uv);
    float size = 2.*mix(10.,1.,r.x+0.5);
    uv -= (0.5 + r.yz * 0.5) * (1. - 1./size);
    uv *= size;
    uv.y = 1. - uv.y;
    if (r.x < cutoff || clamp(uv, 1./32., 31./32.) != uv) return 0.0;
    uv = mix(minCoord, maxCoord, uv);
    return texelFetch(Sampler0, ivec2(uv*textureSize(Sampler0, 0)), 0).r * max(0., r.x-cutoff);
}

vec3 water(vec2 uv, vec2 uv2, float time) {
    vec2 offset;
    vec3 col = clamp(srgb_from_linear_srgb(linear_srgb_from_oklab(clouds(uv*0.15, time*0.01, offset))), 0., 1.);
    uv = uv2 / 15.;
    uv += offset * 0.02;
    float s = stars(uv * 4., time*0.13)*0.1
            + stars(uv*2. - 30., time*0.35 + 80.)*0.5
            + stars(uv*1.5 + 30., time*0.8 - 80.)*0.2;
    float density = starBrightness * (fbm(vec3((uv + offset) * 8., time * 0.008))-densityOffset) / (1.-densityOffset);
    s *= max(0., density);
    col += s*s*50.;
#ifdef PIXELATED
    offset = 0.15*fbm2(vec3(uv2*0.15, time*0.03));
    uv = uv2 / 15.;
    col += ghost(uv + offset * 0.3 - time * vec2(0, 0.15), time, 0.35);
    col += ghost(uv*1.5 - offset * 0.2 - time * vec2(0, 0.2), time, 0.43);
#else
    col += ghost(uv + offset * 0.3 - time * vec2(0, 0.15), time, 0.35);
    col += ghost(uv*4.0 - offset * 0.3 - time * vec2(0, 0.2), time, 0.43);
#endif
    col /= max(1. - s, max(col.r, max(col.g, col.b)));
    col += max(0., density + 0.3) * 0.03;
    return col;
}
