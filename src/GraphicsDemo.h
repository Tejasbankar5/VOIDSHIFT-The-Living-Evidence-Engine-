#ifndef GRAPHICS_DEMO_H
#define GRAPHICS_DEMO_H

#include "GraphicsAlgorithms.h"
#include "Matrix.h"
#include "Transform.h"

class GraphicsDemo {
public:
    int currentMode; // 1-4 Algorithms, 5-10 Transformations, 11 Coord Grid, 12 RGB Lab
    float demoAnimTime;

    // Object switcher (0 = Crewmate, 1 = CCTV Camera)
    int demoObjectType;

    // Interactive Transformation Lab Parameters
    float transX, transY;
    float scaleX, scaleY;
    float rotationAngle;
    float shearX, shearY;
    bool reflectX, reflectY;

    // Interactive RGB Color Lab Parameters
    int colorR, colorG, colorB;

    GraphicsDemo();

    void update(float deltaTime);
    void handleInput(unsigned char key);
    void render(float screenW, float screenH) const;
};

#endif // GRAPHICS_DEMO_H
