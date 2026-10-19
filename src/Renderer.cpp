#include "Renderer.h"
#include <cmath>
#include <cstring>

#ifndef M_PI
#define M_PI 3.14159265358979323846f
#endif

void Renderer::initGL(int width, int height) {
    glViewport(0, 0, width, height);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluOrtho2D(0, width, height, 0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_LINE_SMOOTH);
    glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
}

void Renderer::clear(Color clearColor) {
    glClearColor(clearColor.r, clearColor.g, clearColor.b, clearColor.a);
    glClear(GL_COLOR_BUFFER_BIT);
}

void Renderer::drawPoint(int x, int y, Color color, float pointSize) {
    GraphicsAlgorithms::drawPoint(x, y, color, pointSize);
}

void Renderer::drawRect(float x, float y, float w, float h, Color color, bool filled) {
    glColor4f(color.r, color.g, color.b, color.a);
    if (filled) {
        glBegin(GL_QUADS);
        glVertex2f(x, y);
        glVertex2f(x + w, y);
        glVertex2f(x + w, y + h);
        glVertex2f(x, y + h);
        glEnd();
    } else {
        glLineWidth(2.0f);
        glBegin(GL_LINE_LOOP);
        glVertex2f(x, y);
        glVertex2f(x + w, y);
        glVertex2f(x + w, y + h);
        glVertex2f(x, y + h);
        glEnd();
    }
}

void Renderer::drawCircle(float cx, float cy, float radius, Color color, bool filled, int numSegments) {
    drawEllipse(cx, cy, radius, radius, color, filled, numSegments);
}

void Renderer::drawEllipse(float cx, float cy, float rx, float ry, Color color, bool filled, int numSegments) {
    glColor4f(color.r, color.g, color.b, color.a);
    if (filled) {
        glBegin(GL_TRIANGLE_FAN);
        glVertex2f(cx, cy);
        for (int i = 0; i <= numSegments; ++i) {
            float theta = i * (2.0f * M_PI / numSegments);
            glVertex2f(cx + rx * std::cos(theta), cy + ry * std::sin(theta));
        }
        glEnd();
    } else {
        glLineWidth(2.0f);
        glBegin(GL_LINE_LOOP);
        for (int i = 0; i < numSegments; ++i) {
            float theta = i * (2.0f * M_PI / numSegments);
            glVertex2f(cx + rx * std::cos(theta), cy + ry * std::sin(theta));
        }
        glEnd();
    }
}

void Renderer::drawLine(float x1, float y1, float x2, float y2, Color color, float thickness) {
    glColor4f(color.r, color.g, color.b, color.a);
    glLineWidth(thickness);
    glBegin(GL_LINES);
    glVertex2f(x1, y1);
    glVertex2f(x2, y2);
    glEnd();
}

void Renderer::drawPolygon(const std::vector<Vector2D>& vertices, Color color, bool filled) {
    if (vertices.empty()) return;
    glColor4f(color.r, color.g, color.b, color.a);
    if (filled) {
        glBegin(GL_POLYGON);
        for (const auto& v : vertices) {
            glVertex2f(v.x, v.y);
        }
        glEnd();
    } else {
        glLineWidth(2.0f);
        glBegin(GL_LINE_LOOP);
        for (const auto& v : vertices) {
            glVertex2f(v.x, v.y);
        }
        glEnd();
    }
}

static unsigned char font5x7[128][7];
static bool fontInitialized = false;

static void initFontTable() {
    if (fontInitialized) return;
    std::memset(font5x7, 0, sizeof(font5x7));

    const unsigned char num[10][7] = {
        {0x0E, 0x11, 0x13, 0x15, 0x19, 0x11, 0x0E}, {0x04, 0x0C, 0x04, 0x04, 0x04, 0x04, 0x0E},
        {0x0E, 0x11, 0x01, 0x06, 0x08, 0x10, 0x1F}, {0x1F, 0x02, 0x04, 0x02, 0x01, 0x11, 0x0E},
        {0x02, 0x06, 0x0A, 0x12, 0x1F, 0x02, 0x02}, {0x1F, 0x10, 0x1E, 0x01, 0x01, 0x11, 0x0E},
        {0x06, 0x08, 0x10, 0x1E, 0x11, 0x11, 0x0E}, {0x1F, 0x01, 0x02, 0x04, 0x08, 0x08, 0x08},
        {0x0E, 0x11, 0x11, 0x0E, 0x11, 0x11, 0x0E}, {0x0E, 0x11, 0x11, 0x0F, 0x01, 0x02, 0x0C}
    };
    for (int i = 0; i < 10; ++i) std::memcpy(font5x7['0' + i], num[i], 7);

    const unsigned char alpha[26][7] = {
        {0x0E, 0x11, 0x11, 0x1F, 0x11, 0x11, 0x11}, {0x1E, 0x11, 0x11, 0x1E, 0x11, 0x11, 0x1E},
        {0x0E, 0x11, 0x10, 0x10, 0x10, 0x11, 0x0E}, {0x1C, 0x12, 0x11, 0x11, 0x11, 0x12, 0x1C},
        {0x1F, 0x10, 0x10, 0x1E, 0x10, 0x10, 0x1F}, {0x1F, 0x10, 0x10, 0x1E, 0x10, 0x10, 0x10},
        {0x0E, 0x11, 0x10, 0x13, 0x11, 0x11, 0x0F}, {0x11, 0x11, 0x11, 0x1F, 0x11, 0x11, 0x11},
        {0x0E, 0x04, 0x04, 0x04, 0x04, 0x04, 0x0E}, {0x07, 0x02, 0x02, 0x02, 0x02, 0x12, 0x0C},
        {0x11, 0x12, 0x14, 0x18, 0x14, 0x12, 0x11}, {0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x1F},
        {0x11, 0x1B, 0x15, 0x11, 0x11, 0x11, 0x11}, {0x11, 0x11, 0x19, 0x15, 0x13, 0x11, 0x11},
        {0x0E, 0x11, 0x11, 0x11, 0x11, 0x11, 0x0E}, {0x1E, 0x11, 0x11, 0x1E, 0x10, 0x10, 0x10},
        {0x0E, 0x11, 0x11, 0x11, 0x15, 0x12, 0x0D}, {0x1E, 0x11, 0x11, 0x1E, 0x14, 0x12, 0x11},
        {0x0E, 0x11, 0x10, 0x0E, 0x01, 0x11, 0x0E}, {0x1F, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04},
        {0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x0E}, {0x11, 0x11, 0x11, 0x11, 0x11, 0x0A, 0x04},
        {0x11, 0x11, 0x11, 0x11, 0x15, 0x1B, 0x11}, {0x11, 0x11, 0x0A, 0x04, 0x0A, 0x11, 0x11},
        {0x11, 0x11, 0x0A, 0x04, 0x04, 0x04, 0x04}, {0x1F, 0x01, 0x02, 0x04, 0x08, 0x10, 0x1F}
    };
    for (int i = 0; i < 26; ++i) {
        std::memcpy(font5x7['A' + i], alpha[i], 7);
        std::memcpy(font5x7['a' + i], alpha[i], 7);
    }

    const unsigned char symColon[7] = {0x00, 0x06, 0x06, 0x00, 0x06, 0x06, 0x00};
    const unsigned char symDash[7]  = {0x00, 0x00, 0x00, 0x1F, 0x00, 0x00, 0x00};
    const unsigned char symPlus[7]  = {0x00, 0x04, 0x04, 0x1F, 0x04, 0x04, 0x00};
    const unsigned char symLBrack[7]= {0x0E, 0x08, 0x08, 0x08, 0x08, 0x08, 0x0E};
    const unsigned char symRBrack[7]= {0x0E, 0x02, 0x02, 0x02, 0x02, 0x02, 0x0E};
    const unsigned char symExclam[7]= {0x04, 0x04, 0x04, 0x04, 0x00, 0x04, 0x00};

    std::memcpy(font5x7[':'], symColon, 7);
    std::memcpy(font5x7['-'], symDash, 7);
    std::memcpy(font5x7['+'], symPlus, 7);
    std::memcpy(font5x7['['], symLBrack, 7);
    std::memcpy(font5x7[']'], symRBrack, 7);
    std::memcpy(font5x7['!'], symExclam, 7);

    fontInitialized = true;
}

void Renderer::drawText(float x, float y, const std::string& text, Color color, float scale) {
    initFontTable();
    glColor4f(color.r, color.g, color.b, color.a);
    float currX = x;

    for (char c : text) {
        if (c < 0 || c >= 128) c = '?';
        const unsigned char* glyph = font5x7[(int)c];

        for (int row = 0; row < 7; ++row) {
            unsigned char b = glyph[row];
            for (int col = 0; col < 5; ++col) {
                if (b & (1 << (4 - col))) {
                    drawRect(currX + col * scale * 2.0f, y + row * scale * 2.0f, scale * 2.0f, scale * 2.0f, color, true);
                }
            }
        }
        currX += 6.0f * scale * 2.0f;
    }
}

// Authentic Among Us Astronaut Character Model
void Renderer::drawCrewmate(const Transform& transform, Color bodyColor, bool isDead, float legAnimTime, bool isFacingLeft, bool isLocalPlayer) {
    Matrix3x3 mat = transform.getMatrix();
    if (isFacingLeft) {
        mat = mat * Matrix3x3::ReflectionY();
    }

    auto transformPt = [&](float lx, float ly) {
        return mat.transformPoint(Vector2D(lx, ly));
    };

    Color outlineColor(0.08f, 0.08f, 0.12f, 1.0f);

    if (isDead) {
        Color darkBody(bodyColor.r * 0.7f, bodyColor.g * 0.7f, bodyColor.b * 0.7f, bodyColor.a);
        Vector2D p1 = transformPt(-16.0f, 8.0f);
        Vector2D p2 = transformPt(16.0f, 8.0f);
        Vector2D p3 = transformPt(16.0f, 22.0f);
        Vector2D p4 = transformPt(-16.0f, 22.0f);
        drawPolygon({p1, p2, p3, p4}, outlineColor, true);
        Vector2D pi1 = transformPt(-14.0f, 10.0f);
        Vector2D pi2 = transformPt(14.0f, 10.0f);
        Vector2D pi3 = transformPt(14.0f, 20.0f);
        Vector2D pi4 = transformPt(-14.0f, 20.0f);
        drawPolygon({pi1, pi2, pi3, pi4}, darkBody, true);

        Vector2D b1 = transformPt(-4.0f, 10.0f);
        Vector2D b2 = transformPt(4.0f, 10.0f);
        Vector2D b3 = transformPt(4.0f, -6.0f);
        Vector2D b4 = transformPt(-4.0f, -6.0f);
        drawPolygon({b1, b2, b3, b4}, Color(0.95f, 0.95f, 0.9f, 1.0f), true);
        Vector2D cap = transformPt(0.0f, -9.0f);
        drawCircle(cap.x, cap.y, 7.0f * transform.scale.x, Color(0.95f, 0.95f, 0.9f, 1.0f), true);
        return;
    }

    // Oxygen Backpack
    Vector2D bp1 = transformPt(-24.0f, -10.0f);
    Vector2D bp2 = transformPt(-14.0f, -10.0f);
    Vector2D bp3 = transformPt(-14.0f, 14.0f);
    Vector2D bp4 = transformPt(-24.0f, 14.0f);
    drawPolygon({bp1, bp2, bp3, bp4}, outlineColor, true);
    Vector2D bpi1 = transformPt(-22.0f, -8.0f);
    Vector2D bpi2 = transformPt(-16.0f, -8.0f);
    Vector2D bpi3 = transformPt(-16.0f, 12.0f);
    Vector2D bpi4 = transformPt(-22.0f, 12.0f);
    Color backpackColor(bodyColor.r * 0.82f, bodyColor.g * 0.82f, bodyColor.b * 0.82f, bodyColor.a);
    drawPolygon({bpi1, bpi2, bpi3, bpi4}, backpackColor, true);

    // Legs
    float legOffset = std::sin(legAnimTime * 14.0f) * 5.0f;
    Vector2D legL1 = transformPt(-12.0f, 12.0f + legOffset);
    Vector2D legL2 = transformPt(-3.0f, 12.0f + legOffset);
    Vector2D legL3 = transformPt(-3.0f, 26.0f + legOffset);
    Vector2D legL4 = transformPt(-12.0f, 26.0f + legOffset);
    drawPolygon({legL1, legL2, legL3, legL4}, outlineColor, true);
    Vector2D legLi1 = transformPt(-10.0f, 14.0f + legOffset);
    Vector2D legLi2 = transformPt(-5.0f, 14.0f + legOffset);
    Vector2D legLi3 = transformPt(-5.0f, 24.0f + legOffset);
    Vector2D legLi4 = transformPt(-10.0f, 24.0f + legOffset);
    drawPolygon({legLi1, legLi2, legLi3, legLi4}, bodyColor, true);

    Vector2D legR1 = transformPt(3.0f, 12.0f - legOffset);
    Vector2D legR2 = transformPt(12.0f, 12.0f - legOffset);
    Vector2D legR3 = transformPt(12.0f, 26.0f - legOffset);
    Vector2D legR4 = transformPt(3.0f, 26.0f - legOffset);
    drawPolygon({legR1, legR2, legR3, legR4}, outlineColor, true);
    Vector2D legRi1 = transformPt(5.0f, 14.0f - legOffset);
    Vector2D legRi2 = transformPt(10.0f, 14.0f - legOffset);
    Vector2D legRi3 = transformPt(10.0f, 24.0f - legOffset);
    Vector2D legRi4 = transformPt(5.0f, 24.0f - legOffset);
    drawPolygon({legRi1, legRi2, legRi3, legRi4}, bodyColor, true);

    // Capsule Body
    Vector2D centerTop = transformPt(0.0f, -8.0f);
    Vector2D centerBot = transformPt(0.0f, 8.0f);
    drawCircle(centerTop.x, centerTop.y, 18.0f * transform.scale.x, outlineColor, true);
    drawCircle(centerBot.x, centerBot.y, 18.0f * transform.scale.x, outlineColor, true);
    drawRect(transformPt(-18.0f, -8.0f).x, transformPt(-18.0f, -8.0f).y, 36.0f * transform.scale.x, 16.0f * transform.scale.y, outlineColor, true);

    drawCircle(centerTop.x, centerTop.y, 16.0f * transform.scale.x, bodyColor, true);
    drawCircle(centerBot.x, centerBot.y, 16.0f * transform.scale.x, bodyColor, true);
    drawRect(transformPt(-16.0f, -8.0f).x, transformPt(-16.0f, -8.0f).y, 32.0f * transform.scale.x, 16.0f * transform.scale.y, bodyColor, true);

    // Cyan Visor
    Vector2D vCenter = transformPt(7.0f, -6.0f);
    drawEllipse(vCenter.x, vCenter.y, 11.0f * transform.scale.x, 8.0f * transform.scale.y, outlineColor, true);
    drawEllipse(vCenter.x, vCenter.y, 9.0f * transform.scale.x, 6.0f * transform.scale.y, Color(0.55f, 0.88f, 0.98f, 1.0f), true);
    Vector2D vHL = transformPt(9.0f, -8.0f);
    drawEllipse(vHL.x, vHL.y, 4.0f * transform.scale.x, 2.5f * transform.scale.y, Color(0.9f, 0.98f, 1.0f, 1.0f), true);

    if (isLocalPlayer) {
        Vector2D crownPos = transformPt(0.0f, -30.0f);
        drawPolygon({Vector2D(crownPos.x - 8, crownPos.y + 4), Vector2D(crownPos.x - 10, crownPos.y - 6),
                     Vector2D(crownPos.x - 3, crownPos.y - 1), Vector2D(crownPos.x, crownPos.y - 8),
                     Vector2D(crownPos.x + 3, crownPos.y - 1), Vector2D(crownPos.x + 10, crownPos.y - 6),
                     Vector2D(crownPos.x + 8, crownPos.y + 4)}, Color(1.0f, 0.85f, 0.1f, 1.0f), true);
    }
}

// CCTV Security Camera Object demonstrating 2D Matrix Transformations (Rotation, Shearing, Scaling)
void Renderer::drawCCTVCamera(const Transform& transform, float animTime, Color lensColor) {
    // 2D Transformations:
    // 1. Rotation (Scanning Sweep back & forth)
    float scanAngle = std::sin(animTime * 2.5f) * 0.45f;
    // 2. Shearing (Mechanical Bracket slant)
    float bracketShear = 0.25f * std::cos(animTime * 2.5f);
    // 3. Scaling (Pulsing Red LED lens indicator)
    float pulseScale = 1.0f + 0.35f * std::sin(animTime * 6.0f);

    Transform combined = transform;
    combined.rotation += scanAngle;
    combined.shearX += bracketShear;

    Matrix3x3 mat = combined.getMatrix();

    auto transformPt = [&](float lx, float ly) {
        return mat.transformPoint(Vector2D(lx, ly));
    };

    Color wallMetal(0.35f, 0.4f, 0.48f, 1.0f);
    Color camBody(0.85f, 0.88f, 0.92f, 1.0f);
    Color darkOutline(0.1f, 0.12f, 0.16f, 1.0f);

    // Wall Mounting Bracket
    Vector2D m1 = transformPt(-25.0f, -20.0f);
    Vector2D m2 = transformPt(-15.0f, -20.0f);
    Vector2D m3 = transformPt(-15.0f, 0.0f);
    Vector2D m4 = transformPt(-25.0f, 0.0f);
    drawPolygon({m1, m2, m3, m4}, wallMetal, true);
    drawPolygon({m1, m2, m3, m4}, darkOutline, false);

    // Camera Housing Cylinder Body
    Vector2D b1 = transformPt(-15.0f, -12.0f);
    Vector2D b2 = transformPt(18.0f, -12.0f);
    Vector2D b3 = transformPt(18.0f, 12.0f);
    Vector2D b4 = transformPt(-15.0f, 12.0f);
    drawPolygon({b1, b2, b3, b4}, camBody, true);
    drawPolygon({b1, b2, b3, b4}, darkOutline, false);

    // Camera Front Lens Cone
    Vector2D l1 = transformPt(18.0f, -14.0f);
    Vector2D l2 = transformPt(26.0f, -10.0f);
    Vector2D l3 = transformPt(26.0f, 10.0f);
    Vector2D l4 = transformPt(18.0f, 14.0f);
    drawPolygon({l1, l2, l3, l4}, Color(0.2f, 0.25f, 0.3f, 1.0f), true);

    // Pulsing Red Surveillance LED Lens (Scaling Transformation)
    Vector2D ledCenter = transformPt(26.0f, 0.0f);
    drawCircle(ledCenter.x, ledCenter.y, 6.0f * pulseScale * transform.scale.x, lensColor, true);
    drawCircle(ledCenter.x, ledCenter.y, 10.0f * pulseScale * transform.scale.x, Color(lensColor.r, lensColor.g, lensColor.b, 0.35f), false);

    // Projected Surveillance Cone Light (Semi-transparent Red/Cyan Vision Cone)
    Vector2D coneStart = transformPt(26.0f, 0.0f);
    Vector2D coneR1 = transformPt(160.0f, -60.0f);
    Vector2D coneR2 = transformPt(160.0f, 60.0f);
    drawPolygon({coneStart, coneR1, coneR2}, Color(lensColor.r, lensColor.g, lensColor.b, 0.15f), true);
}

void Renderer::drawDeadBody(float x, float y, Color bodyColor) {
    Transform t(x, y);
    drawCrewmate(t, bodyColor, true);
}

void Renderer::drawVent(float x, float y, bool isHighlighted) {
    Color ventColor = isHighlighted ? Color(1.0f, 0.8f, 0.2f, 1.0f) : Color(0.4f, 0.45f, 0.5f, 1.0f);
    drawRect(x - 20, y - 15, 40, 30, ventColor, true);
    drawRect(x - 20, y - 15, 40, 30, Color(0.1f, 0.1f, 0.15f, 1.0f), false);
    for (int i = -10; i <= 10; i += 6) {
        drawLine(x - 15, y + i, x + 15, y + i, Color(0.15f, 0.18f, 0.22f, 1.0f), 2.0f);
    }
}

void Renderer::drawEmergencyButton(float x, float y, bool isHighlighted) {
    drawRect(x - 25, y - 10, 50, 40, Color(0.3f, 0.35f, 0.4f, 1.0f), true);
    drawCircle(x, y - 10, 20.0f, Color(0.7f, 0.85f, 1.0f, 0.4f), true);
    Color btnColor = isHighlighted ? Color(1.0f, 0.3f, 0.3f, 1.0f) : Color(0.85f, 0.1f, 0.1f, 1.0f);
    drawCircle(x, y - 10, 14.0f, btnColor, true);
}

void Renderer::drawConsole(float x, float y, const std::string& label, Color statusColor, bool isHighlighted) {
    Color baseColor = isHighlighted ? Color(1.0f, 0.85f, 0.3f, 1.0f) : Color(0.25f, 0.3f, 0.38f, 1.0f);
    drawRect(x - 22, y - 22, 44, 44, baseColor, true);
    drawRect(x - 18, y - 18, 36, 26, Color(0.1f, 0.15f, 0.2f, 1.0f), true);
    drawRect(x - 12, y - 12, 24, 14, statusColor, true);
    drawText(x - 16, y + 8, label, Color(1, 1, 1, 1), 0.7f);
}

void Renderer::drawDoor(float x, float y, float w, float h, bool isOpen) {
    if (isOpen) {
        drawRect(x, y, w, h, Color(0.2f, 0.8f, 0.3f, 0.3f), true);
        drawRect(x, y, w, h, Color(0.2f, 0.8f, 0.3f, 1.0f), false);
    } else {
        drawRect(x, y, w, h, Color(0.5f, 0.15f, 0.15f, 1.0f), true);
        drawRect(x, y, w, h, Color(0.9f, 0.2f, 0.2f, 1.0f), false);
        drawLine(x, y, x + w, y + h, Color(0.9f, 0.2f, 0.2f, 1.0f), 2.0f);
        drawLine(x + w, y, x, y + h, Color(0.9f, 0.2f, 0.2f, 1.0f), 2.0f);
    }
}

void Renderer::drawDarknessFOV(float playerX, float playerY, float fovRadius, float screenW, float screenH) {
    glColor4f(0.0f, 0.02f, 0.05f, 0.95f);
    int segments = 48;
    glBegin(GL_TRIANGLE_STRIP);
    for (int i = 0; i <= segments; ++i) {
        float theta = i * (2.0f * M_PI / segments);
        float cosT = std::cos(theta);
        float sinT = std::sin(theta);
        glVertex2f(playerX + fovRadius * cosT, playerY + fovRadius * sinT);
        glVertex2f(playerX + (fovRadius + 800.0f) * cosT, playerY + (fovRadius + 800.0f) * sinT);
    }
    glEnd();
}

void Renderer::drawKillBurst(float x, float y, float animTime) {
    float radius = 10.0f + animTime * 80.0f;
    drawCircle(x, y, radius, Color(0.9f, 0.1f, 0.1f, 0.8f - animTime * 0.8f), true);
    for (int i = 0; i < 8; ++i) {
        float angle = i * (M_PI / 4.0f);
        float px = x + radius * std::cos(angle);
        float py = y + radius * std::sin(angle);
        drawLine(x, y, px, py, Color(1.0f, 0.2f, 0.2f, 1.0f - animTime), 4.0f);
    }
}

void Renderer::drawKillBanner(float screenW, float screenH, const std::string& killMessage) {
    float boxW = 540.0f, boxH = 90.0f;
    float boxX = screenW / 2.0f - boxW / 2.0f;
    float boxY = screenH - 180.0f;

    drawRect(boxX, boxY, boxW, boxH, Color(0.15f, 0.03f, 0.03f, 0.95f), true);
    drawRect(boxX, boxY, boxW, boxH, Color(0.95f, 0.15f, 0.15f, 1.0f), false);
    drawRect(boxX + 4, boxY + 4, boxW - 8, boxH - 8, Color(0.95f, 0.15f, 0.15f, 1.0f), false);

    drawText(screenW / 2.0f - (killMessage.length() * 7.0f), boxY + 32.0f, killMessage, Color(1.0f, 0.95f, 0.95f, 1.0f), 1.3f);
}
