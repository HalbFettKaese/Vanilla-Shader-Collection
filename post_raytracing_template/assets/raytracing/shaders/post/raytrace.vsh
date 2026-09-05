#version 330

#moj_import <raytracing:float_utils.glsl>

uniform sampler2D ItemEntitySampler;

out vec2 texCoord;
flat out mat4 IProjViewMat;
flat out int hasData;

out vec4 clipNear;

void main() {
    vec2 uv = vec2((gl_VertexID << 1) & 2, gl_VertexID & 2);
    hasData = int(ivec4(texelFetch(ItemEntitySampler, ivec2(0, 8), 0) * 255. + .5) == ivec4(255, 0, 0, 255));
    IProjViewMat = mat4(1);
    for (int x = 0; x < 4; ++x) {
        for (int y = 0; y < 4; ++y) {
            vec4 encoded = vec4(
                texelFetch(ItemEntitySampler, ivec2(x, y * 2), 0).xy,
                texelFetch(ItemEntitySampler, ivec2(x, y * 2 + 1), 0).xy
            );
            IProjViewMat[x][y] = decodeColor(encoded);
        }
    }
    
    gl_Position = vec4(uv * 2. - 1., -1.0, 1.0);
    texCoord = uv;
    clipNear = IProjViewMat * gl_Position;
}
