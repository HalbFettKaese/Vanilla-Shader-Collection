#version 330

#moj_import <raytracing:shadertoy.glsl>

uniform sampler2D TranslucentSampler;
uniform sampler2D MainSampler;
uniform sampler2D MainDepthSampler;

in vec2 texCoord;
in vec4 clipNear;
flat in mat4 IProjViewMat;
flat in int hasData;

out vec4 fragColor;

vec3 screenToPos(vec3 screenPos) {
    vec4 temp = IProjViewMat * vec4(screenPos * 2. - 1., 1.);
    return temp.xyz / temp.w;
}

void main() {
    if (hasData == 0) {
        fragColor = texture(MainSampler, texCoord);
        return;
    }
    vec3 fragPos = screenToPos(vec3(texCoord, texture(MainDepthSampler, texCoord).x));
    vec3 nearPos = clipNear.xyz / clipNear.w;

    vec3 rayDir = normalize(fragPos - nearPos);

    vec3 mainColor = texture(MainSampler, texCoord).rgb;
    float fragDist = distance(fragPos, nearPos);
    ray camRay = ray(nearPos, rayDir);
    vec3 color = render(camRay, mainColor, fragDist);
    fragColor = vec4(color, 1);
    return;

    float t = -nearPos.y / rayDir.y;

    if (t < 0.0 || t > fragDist) {
        return;
    }

    vec3 planePos = nearPos + t * rayDir;

    fragColor = mix(vec4(0,0,0,1),vec4(1), mod(dot(floor(planePos.xz), vec2(1)), 2.0));
}