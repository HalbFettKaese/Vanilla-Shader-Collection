#version 330

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <raytracing:float_utils.glsl>

uniform sampler2D Sampler0;

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec2 texCoord1;

flat in int sendData;
flat in mat4 IProjViewMat;

out vec4 fragColor;

void main() {
    if (sendData == 1) {
        ivec2 coords = ivec2(gl_FragCoord);
        fragColor = vec4(1.0, 0.0, 0.0, 1.0);
        if (coords.y < 8 && coords.x < 4) {
            vec4 encoded = encodeFloat(IProjViewMat[coords.x][coords.y / 2]);
            if (coords.y % 2 == 0) {
                fragColor = vec4(encoded.xy, 0, 1);
            } else {
                fragColor = vec4(encoded.zw, 0, 1);
            }
        }
        return;
    }
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    if (color.a < 0.1) {
        discard;
    }
    fragColor = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
}
