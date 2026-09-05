#version 150

#moj_import <fog.glsl>
#moj_import <minimap_settings.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec4 normal;
in float isMap;
in vec4 mappos;
in vec4 glpos;
in vec4 cullpos;

out vec4 fragColor;

void main() {
    float cullProgress = -1.0;
    if (abs(isMap - 1.0) < 0.01) {
        vec2 screenSize = gl_FragCoord.xy/(.5+.5*glpos.xy);

        cullProgress = max(
            max(
                abs(cullpos.x), 
                abs(cullpos.y)
            )/cullpos.w - 1.0, 
            max(
                4.*(length(mappos.xy * vec2(1.0, screenSize.y/screenSize.x)) - 0.5), 
                -cullpos.z
            )
        );
        cullProgress = sign(cullProgress) * borderIntensitySetting * sqrt(abs(cullProgress));
        if (cullProgress > 0.)
            discard;
    }
    cullProgress = clamp(cullProgress + 1.0, 0.0, 1.0);
    vec4 borderColor = borderTypeSetting == 1 ? FogColor : borderColorSetting;
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    if (borderTypeSetting != 0) 
        color = mix(color, borderColor, cullProgress);
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
