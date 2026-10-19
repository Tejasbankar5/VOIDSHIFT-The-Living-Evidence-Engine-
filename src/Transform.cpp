#include "Transform.h"

Transform::Transform()
    : position(0.0f, 0.0f), scale(1.0f, 1.0f), rotation(0.0f), shearX(0.0f), shearY(0.0f), reflectX(false), reflectY(false) {}

Transform::Transform(float x, float y, float sx, float sy, float rot)
    : position(x, y), scale(sx, sy), rotation(rot), shearX(0.0f), shearY(0.0f), reflectX(false), reflectY(false) {}

Matrix3x3 Transform::getMatrix() const {
    // Composite Transformation: M = T * R * S * H * Ref
    Matrix3x3 T = Matrix3x3::Translation(position.x, position.y);
    Matrix3x3 R = Matrix3x3::Rotation(rotation);
    Matrix3x3 S = Matrix3x3::Scaling(scale.x, scale.y);
    Matrix3x3 Hx = Matrix3x3::ShearX(shearX);
    Matrix3x3 Hy = Matrix3x3::ShearY(shearY);
    Matrix3x3 RefX = reflectX ? Matrix3x3::ReflectionX() : Matrix3x3::Identity();
    Matrix3x3 RefY = reflectY ? Matrix3x3::ReflectionY() : Matrix3x3::Identity();

    return T * R * S * Hx * Hy * RefX * RefY;
}

Vector2D Transform::apply(const Vector2D& localPoint) const {
    return getMatrix().transformPoint(localPoint);
}
