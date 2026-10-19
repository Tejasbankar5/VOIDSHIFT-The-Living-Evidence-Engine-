#include "GraphicsDemo.h"
#include "Renderer.h"
#include <string>
#include <cmath>
#include <sstream>
#include <iomanip>

#ifndef M_PI
#define M_PI 3.14159265358979323846f
#endif

GraphicsDemo::GraphicsDemo()
    : currentMode(1), demoAnimTime(0.0f), demoObjectType(0), transX(0.0f), transY(0.0f),
      scaleX(1.0f), scaleY(1.0f), rotationAngle(0.0f), shearX(0.0f), shearY(0.0f),
      reflectX(false), reflectY(false), colorR(255), colorG(128), colorB(40) {}

void GraphicsDemo::update(float deltaTime) {
    demoAnimTime += deltaTime;
}

void GraphicsDemo::handleInput(unsigned char key) {
    if (key >= '0' && key <= '9') {
        currentMode = key - '0';
        if (currentMode == 0) currentMode = 10;
    } else if (key == 'c' || key == 'C') {
        currentMode = 11;
    } else if (key == 'k' || key == 'K') {
        currentMode = 12;
    } else if (key == 'o' || key == 'O') {
        demoObjectType = (demoObjectType + 1) % 2; // Toggle between Crewmate & CCTV Camera
    }

    if (currentMode == 5) {
        if (key == 'w' || key == 'W') transY -= 10.0f;
        if (key == 's' || key == 'S') transY += 10.0f;
        if (key == 'a' || key == 'A') transX -= 10.0f;
        if (key == 'd' || key == 'D') transX += 10.0f;
    } else if (currentMode == 6) {
        if (key == 'w' || key == 'W') scaleX += 0.1f;
        if (key == 's' || key == 'S') scaleX = (std::max)(0.1f, scaleX - 0.1f);
        if (key == 'a' || key == 'A') scaleY = (std::max)(0.1f, scaleY - 0.1f);
        if (key == 'd' || key == 'D') scaleY += 0.1f;
    } else if (currentMode == 7) {
        if (key == 'a' || key == 'A') rotationAngle -= 0.15f;
        if (key == 'd' || key == 'D') rotationAngle += 0.15f;
    } else if (currentMode == 8) {
        if (key == 'x' || key == 'X') reflectX = !reflectX;
        if (key == 'y' || key == 'Y') reflectY = !reflectY;
    } else if (currentMode == 9) {
        if (key == 'w' || key == 'W') shearX += 0.1f;
        if (key == 's' || key == 'S') shearX -= 0.1f;
        if (key == 'a' || key == 'A') shearY -= 0.1f;
        if (key == 'd' || key == 'D') shearY += 0.1f;
    } else if (currentMode == 12) {
        if (key == 'r' || key == 'R') colorR = (colorR + 25) % 256;
        if (key == 'g' || key == 'G') colorG = (colorG + 25) % 256;
        if (key == 'b' || key == 'B') colorB = (colorB + 25) % 256;
    }

    if (key == 'r' || key == 'R') {
        if (currentMode >= 5 && currentMode <= 10) {
            transX = transY = 0.0f;
            scaleX = scaleY = 1.0f;
            rotationAngle = 0.0f;
            shearX = shearY = 0.0f;
            reflectX = reflectY = false;
        }
    }
}

void GraphicsDemo::render(float screenW, float screenH) const {
    Renderer::clear(Color(0.04f, 0.06f, 0.1f, 1.0f));

    Renderer::drawRect(30, 15, screenW - 60, 75, Color(0.08f, 0.12f, 0.18f, 0.95f), true);
    Renderer::drawRect(30, 15, screenW - 60, 75, Color(0.3f, 0.6f, 0.9f, 1.0f), false);

    Renderer::drawText(50, 25, "COMPUTER GRAPHICS ACADEMIC LAB & ALGORITHM DEMO", Color(1, 1, 1, 1), 1.1f);
    Renderer::drawText(50, 52, "[1]DDA [2]BresLine [3]MidCircle [4]BresCircle | [5]Trans [6]Scale [7]Rot [8]Reflect [9]Shear [0]Comp | [C]Grid [K]RGB | ESC=Back", Color(0.95f, 0.95f, 0.3f, 1.0f), 0.7f);

    Renderer::drawRect(30, 100, 400, 580, Color(0.07f, 0.1f, 0.15f, 0.95f), true);
    Renderer::drawRect(30, 100, 400, 580, Color(0.3f, 0.5f, 0.7f, 1.0f), false);

    float canvasX = 445.0f, canvasY = 100.0f;
    float canvasW = screenW - 475.0f, canvasH = 580.0f;
    Renderer::drawRect(canvasX, canvasY, canvasW, canvasH, Color(0.02f, 0.03f, 0.05f, 1.0f), true);
    Renderer::drawRect(canvasX, canvasY, canvasW, canvasH, Color(0.2f, 0.4f, 0.6f, 1.0f), false);

    float centerX = canvasX + canvasW / 2.0f;
    float centerY = canvasY + canvasH / 2.0f;

    if (currentMode == 1) { // DDA Line
        Renderer::drawText(50, 120, "ALGORITHM: DDA LINE DRAWING", Color(0.3f, 0.95f, 0.4f, 1.0f), 1.0f);
        Renderer::drawText(50, 155, "Mathematical Formulation:", Color(1, 1, 1, 1), 0.85f);
        Renderer::drawText(50, 180, "dx = x2 - x1,   dy = y2 - y1", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);
        Renderer::drawText(50, 205, "steps = max(|dx|, |dy|)", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);
        Renderer::drawText(50, 230, "x_inc = dx / steps", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);
        Renderer::drawText(50, 255, "y_inc = dy / steps", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);

        auto steps = GraphicsAlgorithms::drawDDALine(centerX - 180, centerY - 120, centerX + 180, centerY + 120, Color(0, 1, 0, 1), true);

        Renderer::drawText(50, 305, "Rasterization Step Table:", Color(0.9f, 0.9f, 0.3f, 1.0f), 0.85f);
        float stepY = 335.0f;
        for (size_t i = 0; i < steps.size() && i < 12; ++i) {
            Renderer::drawText(50, stepY, steps[i].info, Color(0.8f, 0.8f, 0.8f, 1.0f), 0.7f);
            stepY += 22.0f;
        }

    } else if (currentMode == 2) { // Bresenham Line
        Renderer::drawText(50, 120, "ALGORITHM: BRESENHAM LINE", Color(1.0f, 0.5f, 0.2f, 1.0f), 1.0f);
        Renderer::drawText(50, 155, "Decision Parameter Logic:", Color(1, 1, 1, 1), 0.85f);
        Renderer::drawText(50, 180, "p0 = 2*dy - dx", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);
        Renderer::drawText(50, 205, "If p < 0:  Choose (x+1, y)", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);
        Renderer::drawText(50, 230, "           p_next = p + 2*dy", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);
        Renderer::drawText(50, 255, "Else:      Choose (x+1, y+1)", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);
        Renderer::drawText(50, 280, "           p_next = p + 2(dy - dx)", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);

        auto steps = GraphicsAlgorithms::drawBresenhamLine(centerX - 180, centerY - 140, centerX + 180, centerY + 100, Color(1, 0.5f, 0, 1), true);

        Renderer::drawText(50, 325, "Decision Parameter Trace:", Color(0.9f, 0.9f, 0.3f, 1.0f), 0.85f);
        float stepY = 355.0f;
        for (size_t i = 0; i < steps.size() && i < 11; ++i) {
            Renderer::drawText(50, stepY, steps[i].info, Color(0.8f, 0.8f, 0.8f, 1.0f), 0.7f);
            stepY += 22.0f;
        }

    } else if (currentMode == 3) { // Midpoint Circle
        Renderer::drawText(50, 120, "ALGORITHM: MIDPOINT CIRCLE", Color(0.2f, 0.8f, 1.0f, 1.0f), 1.0f);
        Renderer::drawText(50, 155, "Initial Decision & Symmetry:", Color(1, 1, 1, 1), 0.85f);
        Renderer::drawText(50, 180, "p0 = 1 - radius", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);
        Renderer::drawText(50, 205, "If p < 0:  p_next = p + 2x + 1", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);
        Renderer::drawText(50, 230, "Else:      p_next = p + 2(x - y) + 1", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);
        Renderer::drawText(50, 255, "Plot: 8-Way Symmetry Octants", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);

        auto steps = GraphicsAlgorithms::drawMidpointCircle(centerX, centerY, 140, Color(0, 0.8f, 1, 1), true);

        Renderer::drawText(50, 300, "Octant Decision Trace:", Color(0.9f, 0.9f, 0.3f, 1.0f), 0.85f);
        float stepY = 330.0f;
        for (size_t i = 0; i < steps.size() && i < 12; ++i) {
            Renderer::drawText(50, stepY, steps[i].info, Color(0.8f, 0.8f, 0.8f, 1.0f), 0.7f);
            stepY += 22.0f;
        }

    } else if (currentMode == 4) { // Bresenham Circle
        Renderer::drawText(50, 120, "ALGORITHM: BRESENHAM CIRCLE", Color(1.0f, 0.3f, 0.8f, 1.0f), 1.0f);
        Renderer::drawText(50, 155, "Bresenham Decision Parameter:", Color(1, 1, 1, 1), 0.85f);
        Renderer::drawText(50, 180, "d0 = 3 - 2 * radius", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);
        Renderer::drawText(50, 205, "If d < 0:  d_next = d + 4x + 6", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);
        Renderer::drawText(50, 230, "Else:      d_next = d + 4(x - y) + 10", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);
        Renderer::drawText(50, 255, "Plot: 8-Way Symmetry Octants", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);

        auto steps = GraphicsAlgorithms::drawBresenhamCircle(centerX, centerY, 140, Color(1, 0.2f, 0.8f, 1), true);

        Renderer::drawText(50, 300, "Bresenham Parameter Trace:", Color(0.9f, 0.9f, 0.3f, 1.0f), 0.85f);
        float stepY = 330.0f;
        for (size_t i = 0; i < steps.size() && i < 12; ++i) {
            Renderer::drawText(50, stepY, steps[i].info, Color(0.8f, 0.8f, 0.8f, 1.0f), 0.7f);
            stepY += 22.0f;
        }

    } else if (currentMode >= 5 && currentMode <= 10) { // 2D Homogeneous Matrix Transformations
        std::string transNames[6] = {"TRANSLATION", "SCALING", "ROTATION", "REFLECTION", "SHEARING", "COMPOSITE (M = T*R*S*H)"};
        Renderer::drawText(50, 120, "2D MATRIX LAB: " + transNames[currentMode - 5], Color(1.0f, 0.9f, 0.2f, 1.0f), 0.95f);

        // Object Switcher Indicator
        std::string objStr = (demoObjectType == 0) ? "[O] Target: CREWMATE" : "[O] Target: CCTV CAMERA";
        Renderer::drawText(50, 145, objStr, Color(0.3f, 0.95f, 0.4f, 1.0f), 0.85f);

        Transform tr(centerX + transX, centerY + transY);
        tr.scale = Vector2D(scaleX, scaleY);
        tr.rotation = rotationAngle;
        tr.shearX = shearX;
        tr.shearY = shearY;
        tr.reflectX = reflectX;
        tr.reflectY = reflectY;

        Matrix3x3 mat = tr.getMatrix();

        Renderer::drawText(50, 175, "3x3 Homogeneous Matrix M:", Color(1, 1, 1, 1), 0.85f);

        auto fmt = [](float val) {
            std::stringstream ss;
            ss << std::fixed << std::setprecision(2) << std::setw(6) << val;
            return ss.str();
        };

        std::string row0 = "[ " + fmt(mat.m[0][0]) + "  " + fmt(mat.m[0][1]) + "  " + fmt(mat.m[0][2]) + " ]";
        std::string row1 = "[ " + fmt(mat.m[1][0]) + "  " + fmt(mat.m[1][1]) + "  " + fmt(mat.m[1][2]) + " ]";
        std::string row2 = "[ " + fmt(mat.m[2][0]) + "  " + fmt(mat.m[2][1]) + "  " + fmt(mat.m[2][2]) + " ]";

        Renderer::drawText(50, 200, row0, Color(0.3f, 0.9f, 0.4f, 1.0f), 0.8f);
        Renderer::drawText(50, 225, row1, Color(0.3f, 0.9f, 0.4f, 1.0f), 0.8f);
        Renderer::drawText(50, 250, row2, Color(0.3f, 0.9f, 0.4f, 1.0f), 0.8f);

        Renderer::drawText(50, 290, "Interactive Controls:", Color(0.9f, 0.9f, 0.3f, 1.0f), 0.85f);
        Renderer::drawText(50, 315, "[O] Key : Toggle Crewmate / CCTV Camera", Color(0.95f, 0.85f, 0.2f, 1.0f), 0.75f);

        if (currentMode == 5) {
            Renderer::drawText(50, 340, "W / S : Change Ty (" + fmt(transY) + ")", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);
            Renderer::drawText(50, 365, "A / D : Change Tx (" + fmt(transX) + ")", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);
        } else if (currentMode == 6) {
            Renderer::drawText(50, 340, "W / S : Change Sx (" + fmt(scaleX) + ")", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);
            Renderer::drawText(50, 365, "A / D : Change Sy (" + fmt(scaleY) + ")", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);
        } else if (currentMode == 7) {
            float deg = rotationAngle * (180.0f / M_PI);
            Renderer::drawText(50, 340, "A / D : Change Angle (" + fmt(deg) + " deg)", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);
        } else if (currentMode == 8) {
            Renderer::drawText(50, 340, "X Key : Reflect X-Axis (" + std::string(reflectX ? "ON" : "OFF") + ")", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);
            Renderer::drawText(50, 365, "Y Key : Reflect Y-Axis (" + std::string(reflectY ? "ON" : "OFF") + ")", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);
        } else if (currentMode == 9) {
            Renderer::drawText(50, 340, "W / S : Change Shx (" + fmt(shearX) + ")", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);
            Renderer::drawText(50, 365, "A / D : Change Shy (" + fmt(shearY) + ")", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);
        } else if (currentMode == 10) {
            Renderer::drawText(50, 340, "W/S/A/D/X/Y : Tune Composite Parameters", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);
        }
        Renderer::drawText(50, 400, "Press [R] to RESET parameters", Color(0.7f, 0.7f, 0.7f, 1.0f), 0.75f);

        Vector2D origPt(0.0f, 0.0f);
        Vector2D transPt = mat.transformPoint(origPt);
        Renderer::drawText(50, 440, "Vector Homogeneous Transformation:", Color(1, 1, 1, 1), 0.8f);
        Renderer::drawText(50, 465, "[x'] = M * [x] => (" + fmt(transPt.x) + ", " + fmt(transPt.y) + ")", Color(0.4f, 0.9f, 0.4f, 1.0f), 0.75f);

        // Render transformed Target Object (0 = Crewmate, 1 = CCTV Camera)
        if (demoObjectType == 0) {
            Renderer::drawCrewmate(tr, Color(0.9f, 0.2f, 0.2f, 1.0f), false, demoAnimTime, false);
        } else {
            Renderer::drawCCTVCamera(tr, demoAnimTime);
        }

    } else if (currentMode == 11) { // Coordinate Grid
        Renderer::drawText(50, 120, "2D COORDINATE SYSTEM GRID", Color(0.3f, 0.8f, 1.0f, 1.0f), 1.0f);
        Renderer::drawText(50, 160, "Coordinate Spaces:", Color(1, 1, 1, 1), 0.85f);
        Renderer::drawText(50, 185, "1. World Coordinates  (x, y)", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);
        Renderer::drawText(50, 210, "2. Screen Coordinates (0..1280, 0..720)", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);
        Renderer::drawText(50, 235, "3. Homogeneous Vector [x, y, 1]^T", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);

        Renderer::drawLine(canvasX, centerY, canvasX + canvasW, centerY, Color(0.9f, 0.3f, 0.3f, 1.0f), 2.0f);
        Renderer::drawLine(centerX, canvasY, centerX, canvasY + canvasH, Color(0.3f, 0.9f, 0.3f, 1.0f), 2.0f);

        Renderer::drawText(canvasX + canvasW - 40, centerY + 10, "+X", Color(0.9f, 0.3f, 0.3f, 1.0f), 0.9f);
        Renderer::drawText(centerX + 10, canvasY + 10, "-Y", Color(0.3f, 0.9f, 0.3f, 1.0f), 0.9f);
        Renderer::drawText(centerX + 10, centerY + 10, "(0,0) ORIGIN", Color(1, 1, 1, 1), 0.8f);

    } else if (currentMode == 12) { // RGB Color Lab
        Renderer::drawText(50, 120, "RGB COLOR RASTERIZATION LAB", Color(1.0f, 0.8f, 0.2f, 1.0f), 1.0f);
        Renderer::drawText(50, 160, "Interactive Color Controls:", Color(1, 1, 1, 1), 0.85f);
        Renderer::drawText(50, 190, "Press R : Red Channel   (" + std::to_string(colorR) + " / 255)", Color(0.9f, 0.3f, 0.3f, 1.0f), 0.8f);
        Renderer::drawText(50, 215, "Press G : Green Channel (" + std::to_string(colorG) + " / 255)", Color(0.3f, 0.9f, 0.3f, 1.0f), 0.8f);
        Renderer::drawText(50, 240, "Press B : Blue Channel  (" + std::to_string(colorB) + " / 255)", Color(0.3f, 0.6f, 1.0f, 1.0f), 0.8f);

        Color mixColor(colorR / 255.0f, colorG / 255.0f, colorB / 255.0f, 1.0f);
        Renderer::drawRect(centerX - 120, centerY - 120, 240, 240, mixColor, true);
        Renderer::drawRect(centerX - 120, centerY - 120, 240, 240, Color(1, 1, 1, 1), false);

        std::string hexStr = "RGB(" + std::to_string(colorR) + ", " + std::to_string(colorG) + ", " + std::to_string(colorB) + ")";
        Renderer::drawText(centerX - 80, centerY + 140, hexStr, Color(1, 1, 1, 1), 1.0f);
    }
}
