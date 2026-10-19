#ifndef GRAPHICS_ALGORITHMS_H
#define GRAPHICS_ALGORITHMS_H

#include <vector>
#include <string>
#include <windows.h>
#include <GL/gl.h>
#include "Matrix.h"

struct Color {
    float r, g, b, a;
    Color(float _r = 1.0f, float _g = 1.0f, float _b = 1.0f, float _a = 1.0f)
        : r(_r), g(_g), b(_b), a(_a) {}
};

struct AlgorithmStep {
    int stepIndex;
    int x, y;
    int decisionParam;
    std::string info;
};

class GraphicsAlgorithms {
public:
    // Core pixel plotting
    static void drawPoint(int x, int y, Color color = Color(1, 1, 1, 1), float pointSize = 2.0f);

    // Section 12 Algorithms
    static std::vector<AlgorithmStep> drawDDALine(int x1, int y1, int x2, int y2, Color color = Color(0, 1, 0, 1), bool renderPixels = true);
    static std::vector<AlgorithmStep> drawBresenhamLine(int x1, int y1, int x2, int y2, Color color = Color(1, 0.5f, 0, 1), bool renderPixels = true);
    static std::vector<AlgorithmStep> drawMidpointCircle(int xc, int yc, int radius, Color color = Color(0, 0.8f, 1, 1), bool renderPixels = true);
    static std::vector<AlgorithmStep> drawBresenhamCircle(int xc, int yc, int radius, Color color = Color(1, 0.2f, 0.8f, 1), bool renderPixels = true);

    // Helpers
    static void draw8SymmetryPoints(int xc, int yc, int x, int y, Color color);
};

#endif // GRAPHICS_ALGORITHMS_H
