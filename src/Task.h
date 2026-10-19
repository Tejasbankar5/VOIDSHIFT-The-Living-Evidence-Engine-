#ifndef TASK_H
#define TASK_H

#include <string>
#include <vector>
#include "Renderer.h"
#include "Matrix.h"

enum class TaskType {
    FixWiring,
    FixReactor,
    FuelEngine,
    Calibrate,
    DownloadData,
    UploadData,
    AlignOutput
};

class TaskMiniGame {
public:
    TaskType type;
    std::string title;
    bool isFinished;
    float progress; // 0.0f to 1.0f

    // Mini-game specific variables
    int selectedWire;
    std::vector<int> wireConnections;
    std::vector<int> reactorSequence;
    std::vector<int> playerInputSequence;
    float dialAngle;
    float targetAngle;
    float transferProgress;
    bool isFilling;

    TaskMiniGame(TaskType _type = TaskType::FixWiring);

    void init();
    void update(float deltaTime, float mouseX, float mouseY, bool mouseClicked, bool mouseDown);
    void render(float screenW, float screenH) const;
};

#endif // TASK_H
