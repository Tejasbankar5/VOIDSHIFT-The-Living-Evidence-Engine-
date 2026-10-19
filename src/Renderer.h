#ifndef RENDERER_H
#define RENDERER_H

#include <windows.h>
#include <GL/gl.h>
#include <GL/glu.h>
#include <string>
#include <vector>
#include "Matrix.h"
#include "Transform.h"
#include "GraphicsAlgorithms.h"

class Renderer {
public:
    static void initGL(int width, int height);
    static void clear(Color clearColor = Color(0.05f, 0.07f, 0.12f, 1.0f));

    // Basic Primitives
    static void drawPoint(int x, int y, Color color = Color(1, 1, 1, 1), float pointSize = 2.0f);
    static void drawRect(float x, float y, float w, float h, Color color, bool filled = true);
    static void drawCircle(float cx, float cy, float radius, Color color, bool filled = true, int numSegments = 32);
    static void drawEllipse(float cx, float cy, float rx, float ry, Color color, bool filled = true, int numSegments = 32);
    static void drawLine(float x1, float y1, float x2, float y2, Color color, float thickness = 2.0f);
    static void drawPolygon(const std::vector<Vector2D>& vertices, Color color, bool filled = true);

    // Bitmap Text
    static void drawText(float x, float y, const std::string& text, Color color = Color(1, 1, 1, 1), float scale = 1.0f);

    // Authentic Among Us Character Sprites & Transformed Objects
    static void drawCrewmate(const Transform& transform, Color bodyColor, bool isDead = false, float legAnimTime = 0.0f, bool isFacingLeft = false, bool isLocalPlayer = false);
    static void drawCCTVCamera(const Transform& transform, float animTime, Color lensColor = Color(1.0f, 0.2f, 0.2f, 1.0f));
    static void drawDeadBody(float x, float y, Color bodyColor);
    static void drawVent(float x, float y, bool isHighlighted = false);
    static void drawEmergencyButton(float x, float y, bool isHighlighted = false);
    static void drawConsole(float x, float y, const std::string& label, Color statusColor, bool isHighlighted = false);
    static void drawDoor(float x, float y, float w, float h, bool isOpen);
    static void drawDarknessFOV(float playerX, float playerY, float fovRadius, float screenW, float screenH);

    // Kill Presentation Effects
    static void drawKillBurst(float x, float y, float animTime);
    static void drawKillBanner(float screenW, float screenH, const std::string& killMessage);
};

#endif // RENDERER_H
