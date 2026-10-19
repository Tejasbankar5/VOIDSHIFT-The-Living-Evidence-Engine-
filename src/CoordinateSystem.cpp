#include "CoordinateSystem.h"

CoordinateSystem::CoordinateSystem(int width, int height)
    : screenWidth(width), screenHeight(height), cameraPos(0.0f, 0.0f), zoom(1.0f) {}

void CoordinateSystem::updateScreenSize(int width, int height) {
    screenWidth = width;
    screenHeight = height;
}

Vector2D CoordinateSystem::worldToScreen(const Vector2D& worldPos) const {
    // Screen X = (worldX - cameraX) * zoom + screenWidth / 2
    // Screen Y = (worldY - cameraY) * zoom + screenHeight / 2
    float sx = (worldPos.x - cameraPos.x) * zoom + (screenWidth / 2.0f);
    float sy = (worldPos.y - cameraPos.y) * zoom + (screenHeight / 2.0f);
    return Vector2D(sx, sy);
}

Vector2D CoordinateSystem::screenToWorld(const Vector2D& screenPos) const {
    float wx = (screenPos.x - (screenWidth / 2.0f)) / zoom + cameraPos.x;
    float wy = (screenPos.y - (screenHeight / 2.0f)) / zoom + cameraPos.y;
    return Vector2D(wx, wy);
}

Matrix3x3 CoordinateSystem::getViewMatrix() const {
    // View Matrix: Translate by -cameraPos, then scale by zoom, then translate to center of screen
    Matrix3x3 T_cam = Matrix3x3::Translation(-cameraPos.x, -cameraPos.y);
    Matrix3x3 S_zoom = Matrix3x3::Scaling(zoom, zoom);
    Matrix3x3 T_center = Matrix3x3::Translation(screenWidth / 2.0f, screenHeight / 2.0f);
    return T_center * S_zoom * T_cam;
}

Matrix3x3 CoordinateSystem::getProjectionMatrix() const {
    // Standard 2D Orthographic Projection matrix for OpenGL viewport [0, screenWidth] x [0, screenHeight]
    Matrix3x3 proj;
    proj.m[0][0] = 2.0f / screenWidth;
    proj.m[0][2] = -1.0f;
    proj.m[1][1] = 2.0f / screenHeight;
    proj.m[1][2] = -1.0f;
    return proj;
}
