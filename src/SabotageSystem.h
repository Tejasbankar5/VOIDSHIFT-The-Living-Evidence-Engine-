#ifndef SABOTAGE_SYSTEM_H
#define SABOTAGE_SYSTEM_H

#include "Renderer.h"

enum class SabotageType {
    None,
    Reactor,
    Lights,
    Communications
};

class SabotageSystem {
public:
    SabotageType activeSabotage;
    float timer;
    float maxTimer;
    bool reactorPad1Fixed;
    bool reactorPad2Fixed;

    SabotageSystem();

    void triggerSabotage(SabotageType type);
    void update(float deltaTime);
    void repair();
    void renderUI(float screenW, float screenH) const;
    bool isCriticalFailure() const;
};

#endif // SABOTAGE_SYSTEM_H
