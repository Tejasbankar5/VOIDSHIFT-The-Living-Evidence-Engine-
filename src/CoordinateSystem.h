#ifndef COORDINATE_SYSTEM_H
#define COORDINATE_SYSTEM_H

#include "Matrix.h"

class CoordinateSystem {
public:
    int screenWidth;
    int screenHeight;
    Vector2D cameraPos; // World position camera is centered on
    float zoom;         // Camera scale factor

    CoordinateSystem(int width = 1280, int height = 720);

    void updateScreenSize(int width, int height);
    
    Vector2D worldToScreen(const Vector2D& worldPos) const;
    Vector2D screenToWorld(const Vector2D& screenPos) const;

    Matrix3x3 getViewMatrix() const;
    Matrix3x3 getProjectionMatrix() const;
};

#endif // COORDINATE_SYSTEM_H
