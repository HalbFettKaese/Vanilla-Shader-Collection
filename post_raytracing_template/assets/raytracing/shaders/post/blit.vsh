#version 150

out vec2 texCoord;

void main() {
    vec2 uv = vec2((gl_VertexID << 1) & 2, gl_VertexID & 2);
    gl_Position = vec4(uv * 2. - 1., 1.0, 1.0);
    texCoord = uv;
}
