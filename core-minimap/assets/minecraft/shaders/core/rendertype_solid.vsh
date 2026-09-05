#version 150

#moj_import <light.glsl>
#moj_import <vsh_util.glsl>
#moj_import <minimap_settings.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform vec3 ChunkOffset;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec4 normal;
out float isMap;
out vec4 mappos;
out vec4 glpos;
out vec4 cullpos;

void main() {
    vec3 fullPos = Position + ChunkOffset;
    if (abs(mod(Position.y, 0.5) - 1.5/16.0) < 0.001) {
        cullpos = ProjMat * ModelViewMat * vec4(fullPos, 1.0);
        mat4 orthomat = getOrthoMat(ProjMat, 0.01);
        isMap = 1.0;
        mat3 newMVM = mat3(
            ModelViewMat[0][0], 0, -ModelViewMat[2][0], 
            0,                  1, 0, 
            ModelViewMat[2][0], 0, ModelViewMat[0][0]
        );
        vec3 viewPos = newMVM * fullPos; // Apply y rotation
        viewPos = vec3(viewPos.x, -viewPos.z, viewPos.y); // Manually apply x rotation to look down
        gl_Position = orthomat * vec4(viewPos, 1.0);
        gl_Position.xy /= mapZoomSetting;
        mappos = gl_Position;
        gl_Position /= gl_Position.w;
        gl_Position.xy = mapPositionSetting + .5 * gl_Position.xy;

        vertexDistance = length((ModelViewMat * vec4(Position + ChunkOffset, 1.0)).xyz);
        vertexColor = Color * minecraft_sample_lightmap(Sampler2, UV2);
        texCoord0 = UV0;
        normal = orthomat * ModelViewMat * vec4(Normal, 0.0);
    }
    else {
        isMap = 0.0;
        gl_Position = ProjMat * ModelViewMat * vec4(Position + ChunkOffset, 1.0);

        vertexDistance = length((ModelViewMat * vec4(Position + ChunkOffset, 1.0)).xyz);
        vertexColor = Color * minecraft_sample_lightmap(Sampler2, UV2);
        texCoord0 = UV0;
        normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);
    }
    glpos = gl_Position;
}
