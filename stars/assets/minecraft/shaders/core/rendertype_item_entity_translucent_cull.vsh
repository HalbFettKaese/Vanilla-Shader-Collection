#version 330

#moj_import <minecraft:light.glsl>
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in vec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler0;
uniform sampler2D Sampler2;


out float sphericalVertexDistance;
out float cylindricalVertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec2 texCoord1;
out vec2 texCoord2;

out vec3 position;
out vec4 vNearPos;
flat out vec3 center;
flat out vec3 localZ;
flat out int drawType;
flat out vec4 textureBounds;
flat out vec3 starColor1;
flat out vec3 starColor2;
flat out float starRadius;

vec2[] corners = vec2[](
    vec2(0, 1),
    vec2(0, 0),
    vec2(1, 0),
    vec2(1, 1)
);

void main() {

    sphericalVertexDistance = fog_spherical_distance(Position);
    cylindricalVertexDistance = fog_cylindrical_distance(Position);
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color) * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;
    texCoord1 = UV1;
    texCoord2 = UV2;

    localZ = vec3(0, 0, 1) * mat3(ModelViewMat);

    drawType = 0;
    ivec4 iColor = ivec4(texture(Sampler0, UV0) * 255.);
    if (iColor == ivec4(1, 2, 3, 254)) {
        drawType = 1;
    }
    if (drawType == 0) {
        gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
    } else {
        
        vec2 aSize = vec2(textureSize(Sampler0, 0));
        vec2 uv = floor(UV0 * aSize);
        vec4 tSize1 = texelFetch(Sampler0, ivec2(uv) + ivec2(1, 0), 0) * 255.;
        vec4 tSize2 = texelFetch(Sampler0, ivec2(uv) + ivec2(2, 0), 0) * 255.;
        vec4 encodedRadius = texelFetch(Sampler0, ivec2(uv) + ivec2(3, 0), 0) * 255.;
        starRadius = encodedRadius.x * 256. + encodedRadius.y + encodedRadius.z / 256.;
        starColor1 = texelFetch(Sampler0, ivec2(uv) + ivec2(0, 1), 0).rgb;
        starColor2 = texelFetch(Sampler0, ivec2(uv) + ivec2(1, 1), 0).rgb;
        uv = uv - 1. + vec2(16, 0);
        uv.y -= tSize1.z * 8.;
        textureBounds = vec4(
            uv,
            uv + 256. * vec2(tSize1.x, tSize2.x) + vec2(tSize1.y, tSize2.y)
        ) / aSize.xyxy;


        center = Position;

        vec3 pos = Position;
        pos += (Color.rgb * 255. - 128.) * 100.;

        float d = length(center);

        vec3 camUp = vec3(0, 1, 0);
        vec3 forward = -normalize(Position);
        vec3 left = normalize(cross(camUp, forward));
        vec3 up = cross(forward, left);
        vec2 offset = (corners[gl_VertexID % 4] * 2. - 1.) * max(2., 0.5*sqrt(d)) * 2. * starRadius;
        pos += left * offset.x + up * offset.y + forward * min(starRadius, d - .2);
        
        position = pos;

        gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.);
        vec2 ndc = gl_Position.xy / gl_Position.w;

        vNearPos = inverse(ProjMat * ModelViewMat) * vec4(ndc, -1, 1) * gl_Position.w;
    }
}
