#include "GraphicsAlgorithms.h"
#include <cmath>
#include <algorithm>
#include <sstream>

void GraphicsAlgorithms::drawPoint(int x, int y, Color color, float pointSize) {
    glPointSize(pointSize);
    glColor4f(color.r, color.g, color.b, color.a);
    glBegin(GL_POINTS);
    glVertex2i(x, y);
    glEnd();
}

void GraphicsAlgorithms::draw8SymmetryPoints(int xc, int yc, int x, int y, Color color) {
    drawPoint(xc + x, yc + y, color);
    drawPoint(xc - x, yc + y, color);
    drawPoint(xc + x, yc - y, color);
    drawPoint(xc - x, yc - y, color);
    drawPoint(xc + y, yc + x, color);
    drawPoint(xc - y, yc + x, color);
    drawPoint(xc + y, yc - x, color);
    drawPoint(xc - y, yc - x, color);
}

// Section 12: DDA Line Drawing Algorithm
// dx = x2 - x1, dy = y2 - y1
// steps = max(|dx|, |dy|)
// xinc = dx / steps, yinc = dy / steps
std::vector<AlgorithmStep> GraphicsAlgorithms::drawDDALine(int x1, int y1, int x2, int y2, Color color, bool renderPixels) {
    std::vector<AlgorithmStep> stepsLog;
    float dx = (float)(x2 - x1);
    float dy = (float)(y2 - y1);
    float steps = std::max(std::abs(dx), std::abs(dy));

    if (steps == 0) {
        if (renderPixels) drawPoint(x1, y1, color);
        stepsLog.push_back({0, x1, y1, 0, "Single Point"});
        return stepsLog;
    }

    float xinc = dx / steps;
    float yinc = dy / steps;

    float x = (float)x1;
    float y = (float)y1;

    for (int i = 0; i <= (int)steps; ++i) {
        int px = (int)std::round(x);
        int py = (int)std::round(y);
        if (renderPixels) {
            drawPoint(px, py, color, 3.0f);
        }
        
        std::stringstream ss;
        ss << "Step " << i << ": (" << px << ", " << py << ")";
        stepsLog.push_back({i, px, py, 0, ss.str()});

        x += xinc;
        y += yinc;
    }

    return stepsLog;
}

// Section 12: Bresenham Line Drawing Algorithm
// Uses integer decision parameter p0 = 2dy - dx
std::vector<AlgorithmStep> GraphicsAlgorithms::drawBresenhamLine(int x1, int y1, int x2, int y2, Color color, bool renderPixels) {
    std::vector<AlgorithmStep> stepsLog;

    int dx = std::abs(x2 - x1);
    int dy = std::abs(y2 - y1);
    int sx = (x1 < x2) ? 1 : -1;
    int sy = (y1 < y2) ? 1 : -1;

    int x = x1;
    int y = y1;

    if (dx >= dy) { // Shallow slope (|m| <= 1)
        int p = 2 * dy - dx;
        for (int i = 0; i <= dx; ++i) {
            if (renderPixels) drawPoint(x, y, color, 3.0f);
            
            std::stringstream ss;
            ss << "Step " << i << ": (" << x << ", " << y << ") p=" << p;
            stepsLog.push_back({i, x, y, p, ss.str()});

            if (p >= 0) {
                y += sy;
                p += 2 * (dy - dx);
            } else {
                p += 2 * dy;
            }
            x += sx;
        }
    } else { // Steep slope (|m| > 1)
        int p = 2 * dx - dy;
        for (int i = 0; i <= dy; ++i) {
            if (renderPixels) drawPoint(x, y, color, 3.0f);

            std::stringstream ss;
            ss << "Step " << i << ": (" << x << ", " << y << ") p=" << p;
            stepsLog.push_back({i, x, y, p, ss.str()});

            if (p >= 0) {
                x += sx;
                p += 2 * (dx - dy);
            } else {
                p += 2 * dx;
            }
            y += sy;
        }
    }

    return stepsLog;
}

// Section 12: Midpoint Circle Drawing Algorithm
// Initial decision parameter p0 = 1 - radius
std::vector<AlgorithmStep> GraphicsAlgorithms::drawMidpointCircle(int xc, int yc, int radius, Color color, bool renderPixels) {
    std::vector<AlgorithmStep> stepsLog;
    int x = 0;
    int y = radius;
    int p = 1 - radius; // p0 = 1 - r

    int stepIdx = 0;
    while (x <= y) {
        if (renderPixels) {
            draw8SymmetryPoints(xc, yc, x, y, color);
        }

        std::stringstream ss;
        ss << "Octant Step " << stepIdx << ": (" << x << ", " << y << ") p=" << p;
        stepsLog.push_back({stepIdx++, x, y, p, ss.str()});

        x++;
        if (p < 0) {
            p += 2 * x + 1;
        } else {
            y--;
            p += 2 * (x - y) + 1;
        }
    }

    return stepsLog;
}

// Section 12: Bresenham Circle Drawing Algorithm
// Initial decision parameter d0 = 3 - 2 * radius
std::vector<AlgorithmStep> GraphicsAlgorithms::drawBresenhamCircle(int xc, int yc, int radius, Color color, bool renderPixels) {
    std::vector<AlgorithmStep> stepsLog;
    int x = 0;
    int y = radius;
    int d = 3 - 2 * radius; // d0 = 3 - 2r

    int stepIdx = 0;
    while (x <= y) {
        if (renderPixels) {
            draw8SymmetryPoints(xc, yc, x, y, color);
        }

        std::stringstream ss;
        ss << "Bres Circle Step " << stepIdx << ": (" << x << ", " << y << ") d=" << d;
        stepsLog.push_back({stepIdx++, x, y, d, ss.str()});

        if (d < 0) {
            d += 4 * x + 6;
        } else {
            d += 4 * (x - y) + 10;
            y--;
        }
        x++;
    }

    return stepsLog;
}
