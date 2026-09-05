#version 150

#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat3 IViewRotMat;
uniform int FogShape;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;

void main() {
    vec3 pos = Position;
    if (abs(ProjMat[3][3]) < .001) {
        pos = IViewRotMat * pos;
        pos.x *= sqrt(3.0)/2.;
        gl_Position = ProjMat * ModelViewMat * vec4(pos * IViewRotMat, 1.0);
    } else {
        gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);
    }

    vertexDistance = fog_distance(ModelViewMat, pos, FogShape);
    vertexColor = Color * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;
}
