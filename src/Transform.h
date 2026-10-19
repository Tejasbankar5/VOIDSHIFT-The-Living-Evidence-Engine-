#ifndef TRANSFORM_H
#define TRANSFORM_H

#include "Matrix.h"

class Transform {
public:
    Vector2D position;
    Vector2D scale;
    float rotation; // Radians
    float shearX;
    float shearY;
    bool reflectX;
    bool reflectY;

    Transform();
    Transform(float x, float y, float sx = 1.0f, float sy = 1.0f, float rot = 0.0f);

    Matrix3x3 getMatrix() const;
    Vector2D apply(const Vector2D& localPoint) const;
};

#endif // TRANSFORM_H
