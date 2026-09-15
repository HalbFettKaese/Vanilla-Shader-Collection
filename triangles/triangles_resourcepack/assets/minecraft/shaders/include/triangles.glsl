#ifndef TRIANGLES_INCLUDE
#define TRIANGLES_INCLUDE
#include <minecraft:projection.glsl>
#include <minecraft:globals.glsl>

#define INV_SQRT_3 0.5773502691896257
mat4 getModelViewMat() {
    if (abs(ProjMat[3][3]) > 0.01) return ModelViewMat;
    vec3 localZ = transpose(ModelViewMat)[2].xyz;

    localZ = normalize(vec3(INV_SQRT_3,1.,1.)*localZ);
    vec3 localX, localY;
    if (abs(localZ.y) > 0.99999) {
        localY = transpose(ModelViewMat)[1].xyz;
        localY = normalize(vec3(INV_SQRT_3,1.,1.)*localY);
        localX = cross(localY, localZ);
    } else {
        localX = normalize(cross(vec3(0.,1.,0.),localZ));
        localY = cross(localZ, localX);
    }
    mat3 result = transpose(mat3(localX, localY, localZ));
    result[0] *= INV_SQRT_3;
    return mat4(result);
}

#define ModelViewMat getModelViewMat()
#endif