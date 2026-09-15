
#include <minecraft:projection.glsl>
#include <minecraft:globals.glsl>

#define SQUISH 0.8660254037844386
mat4 getModelViewMat() {
    if (abs(ProjMat[3][3]) > 0.01) return ModelViewMat;
    mat3 result = mat3(ModelViewMat);
    result[0] *= SQUISH;
    return mat4(result);
}

#define ModelViewMat getModelViewMat()