#include "SabotageSystem.h"
#include <string>

SabotageSystem::SabotageSystem()
    : activeSabotage(SabotageType::None), timer(0.0f), maxTimer(30.0f),
      reactorPad1Fixed(false), reactorPad2Fixed(false) {}

void SabotageSystem::triggerSabotage(SabotageType type) {
    if (activeSabotage != SabotageType::None) return;
    activeSabotage = type;

    if (type == SabotageType::Reactor) {
        timer = 30.0f;
        maxTimer = 30.0f;
        reactorPad1Fixed = false;
        reactorPad2Fixed = false;
    } else if (type == SabotageType::Lights) {
        timer = 60.0f;
        maxTimer = 60.0f;
    } else if (type == SabotageType::Communications) {
        timer = 60.0f;
        maxTimer = 60.0f;
    }
}

void SabotageSystem::update(float deltaTime) {
    if (activeSabotage == SabotageType::None) return;

    timer -= deltaTime;
    if (timer <= 0.0f) {
        timer = 0.0f;
    }
}

void SabotageSystem::repair() {
    activeSabotage = SabotageType::None;
    timer = 0.0f;
}

void SabotageSystem::renderUI(float screenW, float screenH) const {
    if (activeSabotage == SabotageType::None) return;

    if (activeSabotage == SabotageType::Reactor) {
        // Red flashing alert box
        Renderer::drawRect(screenW / 2.0f - 200, 20, 400, 40, Color(0.9f, 0.1f, 0.1f, 0.85f), true);
        std::string txt = "REACTOR MELTDOWN IN: " + std::to_string((int)timer) + "s";
        Renderer::drawText(screenW / 2.0f - 160, 32, txt, Color(1, 1, 1, 1), 1.1f);
    } else if (activeSabotage == SabotageType::Lights) {
        Renderer::drawRect(screenW / 2.0f - 180, 20, 360, 40, Color(0.9f, 0.6f, 0.1f, 0.85f), true);
        Renderer::drawText(screenW / 2.0f - 150, 32, "ELECTRICAL LIGHTS MALFUNCTION!", Color(1, 1, 1, 1), 1.0f);
    } else if (activeSabotage == SabotageType::Communications) {
        Renderer::drawRect(screenW / 2.0f - 180, 20, 360, 40, Color(0.2f, 0.6f, 0.9f, 0.85f), true);
        Renderer::drawText(screenW / 2.0f - 140, 32, "COMMUNICATIONS DISRUPTED!", Color(1, 1, 1, 1), 1.0f);
    }
}

bool SabotageSystem::isCriticalFailure() const {
    return (activeSabotage == SabotageType::Reactor && timer <= 0.0f);
}
