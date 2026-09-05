#version 150

#moj_import <light.glsl>
#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform vec3 ChunkOffset;
uniform int FogShape;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec4 normal;

void main() {
    vec3 pos = Position;
    if (length(fract(Position.xz) - 0.5) < 0.05) {
        vec2 center = floor(pos.xz) + 0.5;
        vec2 diff = normalize(pos.xz - center)/sqrt(3.0);
        diff.x *=2./sqrt(3.0);
        center.y += (mod(floor(center.x), 2.0)-0.5)/2.0;
        pos.xz = center+diff;
    }
    pos += ChunkOffset;
    pos.x *= sqrt(3.0)/2.;
    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);

    vertexDistance = fog_distance(ModelViewMat, pos, FogShape);
    vertexColor = Color * minecraft_sample_lightmap(Sampler2, UV2);
    float m = max(vertexColor.r, max(vertexColor.g, vertexColor.b));
    float cutoff = 0.3;
    if (m < cutoff) {
        vertexColor.rgb *= cutoff/m;
    }
    texCoord0 = UV0;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);
}
