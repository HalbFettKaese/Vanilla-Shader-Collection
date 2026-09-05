#version 150

uniform sampler2D DataSampler;
uniform sampler2D TranslucentSampler;

in vec2 texCoord;

out vec4 fragColor;

void main() {
    bool has_display = texelFetch(TranslucentSampler, ivec2(0, 4), 0) == vec4(1, 0, 0, 1);
    ivec2 coords = ivec2(gl_FragCoord.xy);
    if (coords.y == 4) {
        fragColor = has_display ? vec4(0, 0, 1, 1) : vec4(1, 0, 0, 1);
        return;
    }
    if (has_display) {
        // Update on input
        fragColor = texelFetch(TranslucentSampler, coords, 0);
        return;
    }
    fragColor = texture(DataSampler, texCoord);
}
