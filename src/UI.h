#ifndef UI_H
#define UI_H

#include "Renderer.h"
#include "Player.h"
#include "Map.h"
#include "Task.h"
#include <vector>

class UI {
public:
    static void renderHUD(float screenW, float screenH, const Player& localPlayer,
                          const Map& currentMap, float globalTaskProgress,
                          bool isNearTask, bool isNearBody, bool isNearVent, bool isNearEmergency,
                          const std::string& targetBotName, bool showMapOverlay);

    static void renderMiniMap(float screenW, float screenH, const Map& map, const Vector2D& playerPos);

    static void renderMainMenu(float screenW, float screenH, int selectedOption);
    static void renderRoleSelection(float screenW, float screenH, PlayerRole selectedRole);
    static void renderHowToPlay(float screenW, float screenH);
    static void renderSabotageMenu(float screenW, float screenH, int selectedOption);
    static void renderPauseMenu(float screenW, float screenH, int selectedOption);
    static void renderEndGameScreen(float screenW, float screenH, bool crewmatesWon, const std::string& reason);
};

#endif // UI_H
