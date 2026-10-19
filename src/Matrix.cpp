#include "Matrix.h"

Matrix3x3::Matrix3x3() {
    for (int r = 0; r < 3; ++r) {
        for (int c = 0; c < 3; ++c) {
            m[r][c] = (r == c) ? 1.0f : 0.0f;
        }
    }
}

Matrix3x3 Matrix3x3::Identity() {
    return Matrix3x3();
}

Matrix3x3 Matrix3x3::Translation(float tx, float ty) {
    Matrix3x3 mat;
    mat.m[0][2] = tx;
    mat.m[1][2] = ty;
    return mat;
}

Matrix3x3 Matrix3x3::Scaling(float sx, float sy) {
    Matrix3x3 mat;
    mat.m[0][0] = sx;
    mat.m[1][1] = sy;
    return mat;
}

Matrix3x3 Matrix3x3::Rotation(float angleRadians) {
    Matrix3x3 mat;
    float c = std::cos(angleRadians);
    float s = std::sin(angleRadians);
    mat.m[0][0] = c;  mat.m[0][1] = -s;
    mat.m[1][0] = s;  mat.m[1][1] = c;
    return mat;
}

Matrix3x3 Matrix3x3::ReflectionX() {
    Matrix3x3 mat;
    mat.m[1][1] = -1.0f; // y' = -y
    return mat;
}

Matrix3x3 Matrix3x3::ReflectionY() {
    Matrix3x3 mat;
    mat.m[0][0] = -1.0f; // x' = -x
    return mat;
}

Matrix3x3 Matrix3x3::ShearX(float shx) {
    Matrix3x3 mat;
    mat.m[0][1] = shx; // x' = x + shx * y
    return mat;
}

Matrix3x3 Matrix3x3::ShearY(float shy) {
    Matrix3x3 mat;
    mat.m[1][0] = shy; // y' = y + shy * x
    return mat;
}

Matrix3x3 Matrix3x3::multiply(const Matrix3x3& other) const {
    Matrix3x3 res;
    for (int r = 0; r < 3; ++r) {
        for (int c = 0; c < 3; ++c) {
            res.m[r][c] = m[r][0] * other.m[0][c] +
                         m[r][1] * other.m[1][c] +
                         m[r][2] * other.m[2][c];
        }
    }
    return res;
}

Matrix3x3 Matrix3x3::operator*(const Matrix3x3& other) const {
    return multiply(other);
}

Vector2D Matrix3x3::transformPoint(const Vector2D& p) const {
    float x = m[0][0] * p.x + m[0][1] * p.y + m[0][2];
    float y = m[1][0] * p.x + m[1][1] * p.y + m[1][2];
    float w = m[2][0] * p.x + m[2][1] * p.y + m[2][2];
    if (w != 0.0f && w != 1.0f) {
        x /= w;
        y /= w;
    }
    return Vector2D(x, y);
}

Vector3D Matrix3x3::transformVector(const Vector3D& v) const {
    float x = m[0][0] * v.x + m[0][1] * v.y + m[0][2] * v.z;
    float y = m[1][0] * v.x + m[1][1] * v.y + m[1][2] * v.z;
    float z = m[2][0] * v.x + m[2][1] * v.y + m[2][2] * v.z;
    return Vector3D(x, y, z);
}

void Matrix3x3::print() const {
    for (int r = 0; r < 3; ++r) {
        std::cout << "[ " << m[r][0] << ", " << m[r][1] << ", " << m[r][2] << " ]\n";
    }
}
