#include "Task.h"
#include <cmath>

#ifndef M_PI
#define M_PI 3.14159265358979323846f
#endif

TaskMiniGame::TaskMiniGame(TaskType _type)
    : type(_type), isFinished(false), progress(0.0f), selectedWire(-1),
      dialAngle(0.0f), targetAngle(0.0f), transferProgress(0.0f), isFilling(false) {
    init();
}

void TaskMiniGame::init() {
    isFinished = false;
    progress = 0.0f;
    selectedWire = -1;
    wireConnections = {-1, -1, -1, -1};
    reactorSequence = {0, 2, 1, 3};
    playerInputSequence.clear();
    dialAngle = 45.0f;
    targetAngle = 0.0f;
    transferProgress = 0.0f;
    isFilling = false;

    switch (type) {
        case TaskType::FixWiring: title = "Fix Wiring Mini-Game"; break;
        case TaskType::FixReactor: title = "Fix Reactor Mini-Game"; break;
        case TaskType::FuelEngine: title = "Fuel Engine Mini-Game"; break;
        case TaskType::Calibrate: title = "Calibrate Mini-Game"; break;
        case TaskType::DownloadData: title = "Download Data"; break;
        case TaskType::UploadData: title = "Upload Data"; break;
        case TaskType::AlignOutput: title = "Align Output Mini-Game"; break;
    }
}

void TaskMiniGame::update(float deltaTime, float mouseX, float mouseY, bool mouseClicked, bool mouseDown) {
    if (isFinished) return;

    if (type == TaskType::FixWiring) {
        // Wire connecting logic: Left nodes (y: 250, 320, 390, 460), Right nodes (y: 250, 320, 390, 460)
        float leftX = 440.0f, rightX = 840.0f;
        if (mouseClicked) {
            for (int i = 0; i < 4; ++i) {
                float nodeY = 250.0f + i * 70.0f;
                if (std::abs(mouseX - leftX) < 30.0f && std::abs(mouseY - nodeY) < 25.0f) {
                    selectedWire = i;
                } else if (selectedWire != -1 && std::abs(mouseX - rightX) < 30.0f && std::abs(mouseY - nodeY) < 25.0f) {
                    wireConnections[selectedWire] = i;
                    selectedWire = -1;
                }
            }
        }
        // Check if all wires connected matching indices
        int correct = 0;
        for (int i = 0; i < 4; ++i) {
            if (wireConnections[i] == i) correct++;
        }
        progress = correct / 4.0f;
        if (correct == 4) isFinished = true;

    } else if (type == TaskType::FixReactor) {
        // 4 Button keypad matching sequence
        if (mouseClicked) {
            for (int i = 0; i < 4; ++i) {
                float btnX = 480.0f + (i % 2) * 160.0f;
                float btnY = 280.0f + (i / 2) * 140.0f;
                if (mouseX >= btnX && mouseX <= btnX + 130.0f && mouseY >= btnY && mouseY <= btnY + 110.0f) {
                    playerInputSequence.push_back(i);
                    if (playerInputSequence.back() != reactorSequence[playerInputSequence.size() - 1]) {
                        playerInputSequence.clear(); // Reset on wrong button
                    }
                }
            }
        }
        progress = playerInputSequence.size() / 4.0f;
        if (playerInputSequence.size() == 4) isFinished = true;

    } else if (type == TaskType::FuelEngine) {
        // Hold button to fill meter
        float btnX = 540.0f, btnY = 480.0f, btnW = 200.0f, btnH = 60.0f;
        if (mouseDown && mouseX >= btnX && mouseX <= btnX + btnW && mouseY >= btnY && mouseY <= btnY + btnH) {
            transferProgress += deltaTime * 0.4f;
            if (transferProgress >= 1.0f) {
                transferProgress = 1.0f;
                isFinished = true;
            }
        }
        progress = transferProgress;

    } else if (type == TaskType::Calibrate) {
        // Spinning dial calibration
        dialAngle += deltaTime * 180.0f;
        if (dialAngle >= 360.0f) dialAngle -= 360.0f;

        if (mouseClicked) {
            // Success if clicked near 0° or 180° target sector
            if (dialAngle <= 25.0f || dialAngle >= 335.0f) {
                progress = 1.0f;
                isFinished = true;
            }
        }

    } else if (type == TaskType::DownloadData || type == TaskType::UploadData) {
        // Click Download/Upload button then wait for transfer
        float btnX = 540.0f, btnY = 420.0f, btnW = 200.0f, btnH = 50.0f;
        if (!isFilling && mouseClicked && mouseX >= btnX && mouseX <= btnX + btnW && mouseY >= btnY && mouseY <= btnY + btnH) {
            isFilling = true;
        }
        if (isFilling) {
            transferProgress += deltaTime * 0.35f;
            if (transferProgress >= 1.0f) {
                transferProgress = 1.0f;
                isFinished = true;
            }
        }
        progress = transferProgress;

    } else if (type == TaskType::AlignOutput) {
        // Drag slider to 0° angle
        if (mouseDown) {
            float sliderX = mouseX;
            if (sliderX >= 440.0f && sliderX <= 840.0f) {
                dialAngle = ((sliderX - 440.0f) / 400.0f) * 180.0f - 90.0f;
                if (std::abs(dialAngle) < 5.0f) {
                    dialAngle = 0.0f;
                    progress = 1.0f;
                    isFinished = true;
                }
            }
        }
    }
}

void TaskMiniGame::render(float screenW, float screenH) const {
    // Mini-game Overlay Panel Background
    Renderer::drawRect(340, 100, 600, 520, Color(0.1f, 0.14f, 0.2f, 0.95f), true);
    Renderer::drawRect(340, 100, 600, 520, Color(0.3f, 0.6f, 0.9f, 1.0f), false);
    Renderer::drawText(370, 130, title, Color(1, 1, 1, 1), 1.2f);
    Renderer::drawText(370, 580, "Click [X] or ESC to Exit", Color(0.7f, 0.7f, 0.7f, 1.0f), 0.8f);

    // Progress Bar
    Renderer::drawRect(370, 160, 540, 20, Color(0.2f, 0.2f, 0.3f, 1.0f), true);
    Renderer::drawRect(370, 160, 540 * progress, 20, Color(0.2f, 0.9f, 0.4f, 1.0f), true);

    Color wireColors[4] = {Color(0.9f, 0.2f, 0.2f, 1.0f), Color(0.2f, 0.6f, 0.9f, 1.0f), Color(0.9f, 0.8f, 0.2f, 1.0f), Color(0.2f, 0.8f, 0.3f, 1.0f)};

    if (type == TaskType::FixWiring) {
        float leftX = 440.0f, rightX = 840.0f;
        for (int i = 0; i < 4; ++i) {
            float nodeY = 250.0f + i * 70.0f;
            // Left & Right Terminal Nodes
            Renderer::drawCircle(leftX, nodeY, 20.0f, wireColors[i], true);
            Renderer::drawCircle(rightX, nodeY, 20.0f, wireColors[i], true);

            // Existing Connected Wires
            if (wireConnections[i] != -1) {
                float targetY = 250.0f + wireConnections[i] * 70.0f;
                Renderer::drawLine(leftX, nodeY, rightX, targetY, wireColors[i], 6.0f);
            }
        }
    } else if (type == TaskType::FixReactor) {
        for (int i = 0; i < 4; ++i) {
            float btnX = 480.0f + (i % 2) * 160.0f;
            float btnY = 280.0f + (i / 2) * 140.0f;
            Color btnColor = Color(0.2f, 0.4f, 0.7f, 1.0f);
            for (int val : playerInputSequence) {
                if (val == i) btnColor = Color(0.3f, 0.9f, 0.4f, 1.0f);
            }
            Renderer::drawRect(btnX, btnY, 130, 110, btnColor, true);
            Renderer::drawText(btnX + 50, btnY + 45, std::to_string(i + 1), Color(1, 1, 1, 1), 1.5f);
        }
    } else if (type == TaskType::FuelEngine) {
        // Fuel Meter Tank
        Renderer::drawRect(480, 220, 320, 220, Color(0.15f, 0.2f, 0.25f, 1.0f), true);
        Renderer::drawRect(490, 230 + 200 * (1.0f - transferProgress), 300, 200 * transferProgress, Color(0.9f, 0.7f, 0.1f, 1.0f), true);
        // Hold Fuel Button
        Renderer::drawRect(540, 480, 200, 60, Color(0.2f, 0.7f, 0.3f, 1.0f), true);
        Renderer::drawText(565, 500, "HOLD TO FUEL", Color(1, 1, 1, 1), 1.0f);
    } else if (type == TaskType::Calibrate) {
        // Circular Gauge
        float cx = 640.0f, cy = 340.0f, radius = 120.0f;
        Renderer::drawCircle(cx, cy, radius, Color(0.2f, 0.25f, 0.35f, 1.0f), true);
        // Target Sector (Green)
        Renderer::drawCircle(cx, cy - radius + 15, 20.0f, Color(0.2f, 0.9f, 0.3f, 1.0f), true);
        // Rotating Pointer Needle
        float rad = dialAngle * (M_PI / 180.0f);
        Renderer::drawLine(cx, cy, cx + radius * std::sin(rad), cy - radius * std::cos(rad), Color(1.0f, 0.2f, 0.2f, 1.0f), 4.0f);
        Renderer::drawText(520, 500, "Click when needle hits GREEN!", Color(1, 1, 1, 1), 0.9f);
    } else if (type == TaskType::DownloadData || type == TaskType::UploadData) {
        Renderer::drawRect(440, 250, 400, 140, Color(0.15f, 0.18f, 0.25f, 1.0f), true);
        Renderer::drawRect(460, 310, 360 * transferProgress, 30, Color(0.2f, 0.8f, 0.9f, 1.0f), true);
        if (!isFilling) {
            Renderer::drawRect(540, 420, 200, 50, Color(0.3f, 0.6f, 0.9f, 1.0f), true);
            Renderer::drawText(565, 435, "START TRANSFER", Color(1, 1, 1, 1), 0.9f);
        } else {
            Renderer::drawText(520, 435, "TRANSFERRING DATA...", Color(0.9f, 0.9f, 0.2f, 1.0f), 0.9f);
        }
    } else if (type == TaskType::AlignOutput) {
        Renderer::drawRect(440, 350, 400, 20, Color(0.3f, 0.35f, 0.4f, 1.0f), true);
        float sliderX = 440.0f + ((dialAngle + 90.0f) / 180.0f) * 400.0f;
        Renderer::drawRect(sliderX - 15, 330, 30, 60, Color(0.9f, 0.3f, 0.3f, 1.0f), true);
        Renderer::drawText(500, 260, "Align Output Dial to 0 deg", Color(1, 1, 1, 1), 1.0f);
    }
}
