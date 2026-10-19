#ifndef MATRIX_H
#define MATRIX_H

#include <cmath>
#include <iostream>

struct Vector2D {
    float x, y;
    Vector2D(float _x = 0.0f, float _y = 0.0f) : x(_x), y(_y) {}
};

struct Vector3D {
    float x, y, z;
    Vector3D(float _x = 0.0f, float _y = 0.0f, float _z = 1.0f) : x(_x), y(_y), z(_z) {}
};

// 3x3 Matrix for 2D Homogeneous Transformations
// [ m[0][0]  m[0][1]  m[0][2] ]
// [ m[1][0]  m[1][1]  m[1][2] ]
// [ m[2][0]  m[2][1]  m[2][2] ]
struct Matrix3x3 {
    float m[3][3];

    Matrix3x3(); // Initializes as Identity Matrix

    static Matrix3x3 Identity();
    static Matrix3x3 Translation(float tx, float ty);
    static Matrix3x3 Scaling(float sx, float sy);
    static Matrix3x3 Rotation(float angleRadians);
    static Matrix3x3 ReflectionX(); // Flip y (x-axis reflection)
    static Matrix3x3 ReflectionY(); // Flip x (y-axis reflection)
    static Matrix3x3 ShearX(float shx);
    static Matrix3x3 ShearY(float shy);

    Matrix3x3 multiply(const Matrix3x3& other) const;
    Matrix3x3 operator*(const Matrix3x3& other) const;

    Vector2D transformPoint(const Vector2D& p) const;
    Vector3D transformVector(const Vector3D& v) const;

    void print() const;
};

#endif // MATRIX_H
