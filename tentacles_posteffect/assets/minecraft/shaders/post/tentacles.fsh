#version 330
#extension GL_ARB_separate_shader_objects : require

#include <minecraft:globals.glsl>

#define iTime (GameTime * 1200.0)

uniform sampler2D InSampler;
uniform sampler2D EyesSampler;

layout(location = 0) in vec2 texCoord;

layout(location = 0) out vec4 fragColor;

#define PI 3.14159
float hash13(vec3 p3)
{
	p3  = fract(p3 * .1031);
    p3 += dot(p3, p3.zyx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

vec2 gradient(vec3 p) {
    float angle = hash13(p) * 2.*PI;
    
    return vec2(cos(angle), sin(angle));
}

float noise(vec3 p) {
    vec3 fl = floor(p);
    vec2 fr = fract(p.xy);
    float r1 = dot(fr, gradient(fl));
    float r2 = dot(fr-vec2(0,1), gradient(fl + vec3(0, 1, 0)));
    float r3 = dot(fr-vec2(1,0), gradient(fl + vec3(1, 0, 0)));
    float r4 = dot(fr-vec2(1,1), gradient(fl + vec3(1, 1, 0)));
    
    fr = smoothstep(0.0, 1.0, fr);
    return mix(mix(r1, r2, fr.y), mix(r3, r4, fr.y), fr.x);
}
vec3 tentacle(vec2 uv) {
    uv.x *= 10.;
    float id = floor(uv.x);
    uv.x = fract(uv.x);
    
    uv.x += uv.y * 0.15 * noise(vec3(uv.y * 13., iTime, id * 2.2));
    uv.x -= .5;
    uv.x = abs(uv.x);
    uv.x *= 2.0;
    
    return vec3(smoothstep(0.9, 1., uv.x + uv.y));
}

void main(){

    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = texCoord;
    uv -= vec2(0.5);
    uv = vec2(atan(uv.y, uv.x), length(uv));
    float vignette = max(0., min(1., (0.6 - uv.y)*2.2));
    uv.y = 1.3 - uv.y;
    // uv.x from [-pi, pi] to [0, 1]
    uv.x = uv.x / PI * 0.5 + 0.5;
    vec3 col = tentacle(uv);
    col *= vignette;
    
    uv = texCoord;
    
    float r1 = 0.003*noise(vec3(uv * 40., iTime));
    float r2 = 0.003*noise(vec3(uv * 40., iTime+1.));
    uv += mix(r1, r2, fract(iTime));
    vec3 texColor = texture(InSampler, uv).rgb;
    float grayScale = dot(texColor, vec3(0.2, 0.7, 0.1));
    texColor = mix(vec3(grayScale), texColor, 0.4);
    texColor *= col;

    vec4 eyesColor = texture(EyesSampler, texCoord);

    eyesColor.a -= 1. - eyesColor.b + sin(iTime + 1.6 * eyesColor.g * 255.);
    eyesColor.a = max(0., min(1., eyesColor.a));
    eyesColor.a = step(0.3, eyesColor.a);

    texColor = mix(texColor, eyesColor.rrr, eyesColor.a);
    // Output to screen
    fragColor = vec4(texColor,1.0);
}
