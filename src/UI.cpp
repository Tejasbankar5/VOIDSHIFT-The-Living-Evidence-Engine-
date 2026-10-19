#include "UI.h"

void UI::renderHUD(float screenW, float screenH, const Player& localPlayer,
                   const Map& currentMap, float globalTaskProgress,
                   bool isNearTask, bool isNearBody, bool isNearVent, bool isNearEmergency,
                   const std::string& targetBotName, bool showMapOverlay) {

    // Top Task Progress Bar
    Renderer::drawRect(15, 15, 340, 45, Color(0.1f, 0.12f, 0.18f, 0.85f), true);
    Renderer::drawRect(15, 15, 340, 45, Color(0.4f, 0.5f, 0.65f, 1.0f), false);
    Renderer::drawText(25, 22, "TOTAL TASKS COMPLETED", Color(1, 1, 1, 1), 0.75f);
    Renderer::drawRect(25, 40, 320, 12, Color(0.2f, 0.2f, 0.3f, 1.0f), true);
    Renderer::drawRect(25, 40, 320 * globalTaskProgress, 12, Color(0.2f, 0.9f, 0.4f, 1.0f), true);

    // Player Role & Station Level Banner
    Color roleColor = (localPlayer.role == PlayerRole::Impostor) ? Color(0.95f, 0.2f, 0.2f, 1.0f) : Color(0.3f, 0.85f, 0.95f, 1.0f);
    std::string roleTxt = (localPlayer.role == PlayerRole::Impostor) ? "ROLE: IMPOSTOR" : "ROLE: CREWMATE";
    Renderer::drawText(25, 72, roleTxt, roleColor, 1.0f);
    Renderer::drawText(25, 92, currentMap.stationName, Color(0.7f, 0.7f, 0.7f, 1.0f), 0.8f);

    // Left Side Task List Checkbox UI or Kill Cooldown Status Bar
    if (localPlayer.role == PlayerRole::Crewmate) {
        Renderer::drawRect(15, 120, 250, 180, Color(0.08f, 0.1f, 0.15f, 0.85f), true);
        Renderer::drawText(25, 130, "Assigned Tasks:", Color(0.9f, 0.9f, 0.3f, 1.0f), 0.8f);
        float taskY = 155.0f;
        for (const auto& task : currentMap.taskSpots) {
            Color tColor = task.isCompleted ? Color(0.3f, 0.9f, 0.4f, 1.0f) : Color(0.85f, 0.85f, 0.85f, 1.0f);
            std::string statusMark = task.isCompleted ? "[X] " : "[ ] ";
            Renderer::drawText(25, taskY, statusMark + task.taskName, tColor, 0.7f);
            taskY += 22.0f;
        }
    } else {
        // Impostor Kill Cooldown Bar
        Renderer::drawRect(15, 120, 250, 65, Color(0.18f, 0.08f, 0.08f, 0.85f), true);
        Renderer::drawRect(15, 120, 250, 65, Color(0.9f, 0.2f, 0.2f, 1.0f), false);
        if (localPlayer.killCooldown > 0.0f) {
            std::string cdTxt = "KILL COOLDOWN: " + std::to_string((int)localPlayer.killCooldown) + "s";
            Renderer::drawText(25, 130, cdTxt, Color(1, 1, 1, 1), 0.75f);
            float cdProgress = 1.0f - (localPlayer.killCooldown / localPlayer.maxKillCooldown);
            Renderer::drawRect(25, 155, 230, 12, Color(0.3f, 0.1f, 0.1f, 1.0f), true);
            Renderer::drawRect(25, 155, 230 * cdProgress, 12, Color(0.9f, 0.2f, 0.2f, 1.0f), true);
        } else {
            Renderer::drawText(25, 138, "KILL COOLDOWN: READY", Color(0.3f, 0.95f, 0.4f, 1.0f), 0.85f);
        }
    }

    // Explicit Context-Sensitive Prompt Overlay
    float promptX = screenW / 2.0f - 150.0f;
    float promptY = screenH - 120.0f;

    if (isNearTask) {
        Renderer::drawRect(promptX, promptY, 300, 45, Color(0.1f, 0.6f, 0.3f, 0.9f), true);
        Renderer::drawText(promptX + 30, promptY + 14, "[ E ] PERFORM TASK", Color(1, 1, 1, 1), 1.0f);
    } else if (isNearEmergency) {
        Renderer::drawRect(promptX, promptY, 300, 45, Color(0.9f, 0.1f, 0.1f, 0.9f), true);
        Renderer::drawText(promptX + 20, promptY + 14, "[ E ] EMERGENCY MEETING", Color(1, 1, 1, 1), 0.9f);
    } else if (isNearBody) {
        Renderer::drawRect(promptX, promptY, 300, 45, Color(0.9f, 0.15f, 0.15f, 0.9f), true);
        Renderer::drawText(promptX + 50, promptY + 14, "[ R ] REPORT BODY", Color(1, 1, 1, 1), 1.0f);
    } else if (isNearVent && localPlayer.role == PlayerRole::Impostor) {
        Renderer::drawRect(promptX, promptY, 300, 45, Color(0.9f, 0.6f, 0.1f, 0.9f), true);
        Renderer::drawText(promptX + 55, promptY + 14, "[ V ] ENTER VENT", Color(1, 1, 1, 1), 1.0f);
    } else if (localPlayer.role == PlayerRole::Impostor) {
        if (!targetBotName.empty() && localPlayer.canKill()) {
            Renderer::drawRect(promptX, promptY, 300, 45, Color(0.95f, 0.1f, 0.1f, 0.95f), true);
            std::string promptTxt = "KILL " + targetBotName + " [SPACE]";
            Renderer::drawText(promptX + 15, promptY + 14, promptTxt, Color(1, 1, 1, 1), 0.95f);
        } else {
            Renderer::drawRect(promptX, promptY, 300, 45, Color(0.25f, 0.25f, 0.3f, 0.7f), true);
            std::string noTargetTxt = (localPlayer.killCooldown > 0.0f) ? "ON COOLDOWN" : "NO TARGET";
            Renderer::drawText(promptX + 80, promptY + 14, noTargetTxt, Color(0.7f, 0.7f, 0.7f, 1.0f), 0.95f);
        }
    }

    // Dynamic HUD Action Buttons Bottom Right
    float btnX = screenW - 90.0f;
    float btnY = screenH - 90.0f;

    // USE / TASK Button (E key)
    Color useBtnColor = (isNearTask || isNearEmergency) ? Color(0.2f, 0.8f, 0.4f, 1.0f) : Color(0.3f, 0.35f, 0.4f, 0.5f);
    Renderer::drawCircle(btnX, btnY, 35.0f, useBtnColor, true);
    Renderer::drawText(btnX - 16.0f, btnY - 8.0f, "USE (E)", Color(1, 1, 1, 1), 0.75f);

    // REPORT Button (R key)
    Color reportBtnColor = isNearBody ? Color(0.9f, 0.2f, 0.2f, 1.0f) : Color(0.3f, 0.35f, 0.4f, 0.5f);
    Renderer::drawCircle(btnX - 85.0f, btnY, 35.0f, reportBtnColor, true);
    Renderer::drawText(btnX - 105.0f, btnY - 8.0f, "REPORT(R)", Color(1, 1, 1, 1), 0.7f);

    // MAP Button (M key)
    Renderer::drawCircle(btnX, btnY - 85.0f, 35.0f, Color(0.2f, 0.6f, 0.9f, 1.0f), true);
    Renderer::drawText(btnX - 18.0f, btnY - 93.0f, "MAP (M)", Color(1, 1, 1, 1), 0.75f);

    // Impostor Action Buttons (Kill SPACE, Vent V, Sabotage Q)
    if (localPlayer.role == PlayerRole::Impostor) {
        bool canKillNow = (!targetBotName.empty() && localPlayer.canKill());
        Color killColor = canKillNow ? Color(0.95f, 0.1f, 0.1f, 1.0f) : Color(0.4f, 0.2f, 0.2f, 0.5f);
        Renderer::drawCircle(btnX - 170.0f, btnY, 35.0f, killColor, true);
        Renderer::drawText(btnX - 192.0f, btnY - 8.0f, "KILL (SPACE)", Color(1, 1, 1, 1), 0.65f);

        Color ventColor = isNearVent ? Color(0.9f, 0.7f, 0.1f, 1.0f) : Color(0.3f, 0.35f, 0.4f, 0.5f);
        Renderer::drawCircle(btnX - 85.0f, btnY - 85.0f, 35.0f, ventColor, true);
        Renderer::drawText(btnX - 103.0f, btnY - 93.0f, "VENT (V)", Color(1, 1, 1, 1), 0.75f);

        Renderer::drawCircle(btnX - 170.0f, btnY - 85.0f, 35.0f, Color(0.8f, 0.3f, 0.1f, 1.0f), true);
        Renderer::drawText(btnX - 192.0f, btnY - 93.0f, "SABOTAGE(Q)", Color(1, 1, 1, 1), 0.65f);
    }

    if (showMapOverlay) {
        renderMiniMap(screenW, screenH, currentMap, localPlayer.transform.position);
    }
}

void UI::renderMiniMap(float screenW, float screenH, const Map& map, const Vector2D& playerPos) {
    Renderer::drawRect(160, 60, 960, 600, Color(0.05f, 0.08f, 0.14f, 0.92f), true);
    Renderer::drawRect(160, 60, 960, 600, Color(0.3f, 0.6f, 0.9f, 1.0f), false);
    Renderer::drawText(200, 85, "STATION MINI-MAP OVERLAY", Color(1, 1, 1, 1), 1.2f);
    Renderer::drawText(850, 85, "[M] Close Map", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.9f);

    float mapScale = 0.5f;
    float mapOffsetX = 220.0f;
    float mapOffsetY = 140.0f;

    for (const auto& room : map.rooms) {
        Renderer::drawRect(mapOffsetX + room.bounds.x * mapScale, mapOffsetY + room.bounds.y * mapScale,
                           room.bounds.w * mapScale, room.bounds.h * mapScale, room.floorColor, true);
        Renderer::drawRect(mapOffsetX + room.bounds.x * mapScale, mapOffsetY + room.bounds.y * mapScale,
                           room.bounds.w * mapScale, room.bounds.h * mapScale, Color(0.4f, 0.6f, 0.8f, 1.0f), false);
        Renderer::drawText(mapOffsetX + (room.bounds.x + 10) * mapScale, mapOffsetY + (room.bounds.y + 10) * mapScale, room.name, Color(1, 1, 1, 0.8f), 0.6f);
    }

    for (const auto& task : map.taskSpots) {
        if (!task.isCompleted) {
            Renderer::drawCircle(mapOffsetX + task.position.x * mapScale, mapOffsetY + task.position.y * mapScale, 6.0f, Color(0.9f, 0.8f, 0.1f, 1.0f), true);
        }
    }

    Renderer::drawCircle(mapOffsetX + playerPos.x * mapScale, mapOffsetY + playerPos.y * mapScale, 8.0f, Color(0.2f, 0.95f, 0.3f, 1.0f), true);
}

void UI::renderMainMenu(float screenW, float screenH, int selectedOption) {
    Renderer::clear(Color(0.04f, 0.06f, 0.1f, 1.0f));

    for (int i = 0; i < 80; ++i) {
        float sx = (i * 157) % (int)screenW;
        float sy = (i * 313) % (int)screenH;
        Renderer::drawPoint(sx, sy, Color(1, 1, 1, 0.6f), 2.0f);
    }

    Renderer::drawText(screenW / 2.0f - 240, 110, "================================", Color(0.3f, 0.7f, 0.9f, 1.0f), 1.2f);
    Renderer::drawText(screenW / 2.0f - 210, 150, "    AMONG US — 2D SPACE    ", Color(0.95f, 0.95f, 1.0f, 1.0f), 1.5f);
    Renderer::drawText(screenW / 2.0f - 240, 190, "================================", Color(0.3f, 0.7f, 0.9f, 1.0f), 1.2f);

    std::string options[5] = {"START GAME", "SELECT YOUR ROLE", "HOW TO PLAY", "GRAPHICS LAB", "EXIT"};
    for (int i = 0; i < 5; ++i) {
        float optY = 270.0f + i * 60.0f;
        Color boxColor = (selectedOption == i) ? Color(0.2f, 0.5f, 0.8f, 0.9f) : Color(0.12f, 0.15f, 0.22f, 0.8f);
        Color txtColor = (selectedOption == i) ? Color(1.0f, 0.9f, 0.3f, 1.0f) : Color(0.8f, 0.85f, 0.9f, 1.0f);

        Renderer::drawRect(screenW / 2.0f - 180, optY, 360, 48, boxColor, true);
        Renderer::drawRect(screenW / 2.0f - 180, optY, 360, 48, Color(0.4f, 0.7f, 1.0f, 1.0f), false);
        Renderer::drawText(screenW / 2.0f - 100, optY + 15, options[i], txtColor, 1.0f);
    }

    Renderer::drawText(screenW / 2.0f - 160, 630, "Use UP/DOWN Arrows & ENTER to select", Color(0.6f, 0.6f, 0.7f, 1.0f), 0.8f);
}

void UI::renderRoleSelection(float screenW, float screenH, PlayerRole selectedRole) {
    Renderer::clear(Color(0.04f, 0.06f, 0.1f, 1.0f));

    Renderer::drawRect(screenW / 2.0f - 260, 100, 520, 520, Color(0.08f, 0.12f, 0.18f, 0.95f), true);
    Renderer::drawRect(screenW / 2.0f - 260, 100, 520, 520, Color(0.3f, 0.6f, 0.9f, 1.0f), false);

    Renderer::drawText(screenW / 2.0f - 150, 140, "SELECT YOUR ROLE", Color(1, 1, 1, 1), 1.4f);

    Color crewBg = (selectedRole == PlayerRole::Crewmate) ? Color(0.2f, 0.6f, 0.9f, 0.9f) : Color(0.12f, 0.18f, 0.25f, 0.8f);
    Renderer::drawRect(screenW / 2.0f - 200, 220, 400, 110, crewBg, true);
    Renderer::drawRect(screenW / 2.0f - 200, 220, 400, 110, Color(0.3f, 0.8f, 1.0f, 1.0f), false);
    Renderer::drawText(screenW / 2.0f - 80, 245, "CREWMATE", Color(1, 1, 1, 1), 1.3f);
    Renderer::drawText(screenW / 2.0f - 160, 285, "Complete tasks, report bodies, repair sabotages.", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.7f);

    Color impBg = (selectedRole == PlayerRole::Impostor) ? Color(0.8f, 0.2f, 0.2f, 0.9f) : Color(0.25f, 0.12f, 0.12f, 0.8f);
    Renderer::drawRect(screenW / 2.0f - 200, 370, 400, 110, impBg, true);
    Renderer::drawRect(screenW / 2.0f - 200, 370, 400, 110, Color(1.0f, 0.3f, 0.3f, 1.0f), false);
    Renderer::drawText(screenW / 2.0f - 80, 395, "IMPOSTOR", Color(1, 1, 1, 1), 1.3f);
    Renderer::drawText(screenW / 2.0f - 160, 435, "Eliminate crewmates, vent, and sabotage systems.", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.7f);

    Renderer::drawText(screenW / 2.0f - 180, 540, "Press UP/DOWN to toggle | ENTER to Confirm", Color(0.9f, 0.9f, 0.3f, 1.0f), 0.8f);
}

void UI::renderHowToPlay(float screenW, float screenH) {
    Renderer::clear(Color(0.04f, 0.06f, 0.1f, 1.0f));

    Renderer::drawRect(80, 60, screenW - 160, screenH - 120, Color(0.08f, 0.12f, 0.18f, 0.95f), true);
    Renderer::drawRect(80, 60, screenW - 160, screenH - 120, Color(0.3f, 0.6f, 0.9f, 1.0f), false);

    Renderer::drawText(screenW / 2.0f - 120, 95, "HOW TO PLAY & CONTROLS", Color(1, 1, 1, 1), 1.3f);

    Renderer::drawText(120, 145, "MOVEMENT:", Color(0.9f, 0.9f, 0.3f, 1.0f), 0.9f);
    Renderer::drawText(140, 175, "W / A / S / D  or  Arrow Keys : Move Character", Color(0.9f, 0.9f, 0.9f, 1.0f), 0.8f);

    Renderer::drawText(120, 215, "GENERAL:", Color(0.9f, 0.9f, 0.3f, 1.0f), 0.9f);
    Renderer::drawText(140, 245, "E Key   : Interact / Perform Task / Emergency Meeting", Color(0.9f, 0.9f, 0.9f, 1.0f), 0.8f);
    Renderer::drawText(140, 270, "R Key   : Report Dead Body", Color(0.9f, 0.9f, 0.9f, 1.0f), 0.8f);
    Renderer::drawText(140, 295, "M Key   : Toggle Mini-Map Overlay", Color(0.9f, 0.9f, 0.9f, 1.0f), 0.8f);
    Renderer::drawText(140, 320, "TAB Key : Show/Hide Task List & Scoreboard", Color(0.9f, 0.9f, 0.9f, 1.0f), 0.8f);
    Renderer::drawText(140, 345, "ESC Key : Pause Menu", Color(0.9f, 0.9f, 0.9f, 1.0f), 0.8f);

    Renderer::drawText(120, 385, "IMPOSTOR CONTROLS:", Color(0.95f, 0.3f, 0.3f, 1.0f), 0.9f);
    Renderer::drawText(140, 415, "SPACE Key : Eliminate Nearby Crewmate", Color(0.9f, 0.9f, 0.9f, 1.0f), 0.8f);
    Renderer::drawText(140, 440, "Q Key     : Open Sabotage Menu (Lights, Reactor, Comms)", Color(0.9f, 0.9f, 0.9f, 1.0f), 0.8f);
    Renderer::drawText(140, 465, "V Key     : Enter/Exit Vent (Use A/D to travel connected vents)", Color(0.9f, 0.9f, 0.9f, 1.0f), 0.8f);

    Renderer::drawText(120, 505, "COMPUTER GRAPHICS LAB:", Color(0.3f, 0.9f, 0.4f, 1.0f), 0.9f);
    Renderer::drawText(140, 535, "G Key : Open Academic Graphics Lab directly during gameplay", Color(0.9f, 0.9f, 0.9f, 1.0f), 0.8f);

    Renderer::drawText(screenW / 2.0f - 140, 600, "Press ESC to Return to Main Menu", Color(0.7f, 0.7f, 0.7f, 1.0f), 0.9f);
}

void UI::renderSabotageMenu(float screenW, float screenH, int selectedOption) {
    Renderer::drawRect(screenW / 2.0f - 180, 180, 360, 320, Color(0.12f, 0.08f, 0.08f, 0.95f), true);
    Renderer::drawRect(screenW / 2.0f - 180, 180, 360, 320, Color(0.9f, 0.2f, 0.2f, 1.0f), false);

    Renderer::drawText(screenW / 2.0f - 110, 210, "SABOTAGE MENU", Color(1, 1, 1, 1), 1.2f);

    std::string sabOpts[3] = {"LIGHTS (Darkness FOV)", "REACTOR (25s Meltdown)", "COMMUNICATIONS (Disrupt UI)"};
    for (int i = 0; i < 3; ++i) {
        float optY = 260.0f + i * 65.0f;
        Color boxCol = (selectedOption == i) ? Color(0.8f, 0.2f, 0.2f, 0.9f) : Color(0.2f, 0.12f, 0.12f, 0.8f);
        Renderer::drawRect(screenW / 2.0f - 150, optY, 300, 50, boxCol, true);
        Renderer::drawRect(screenW / 2.0f - 150, optY, 300, 50, Color(1, 0.3f, 0.3f, 1.0f), false);
        Renderer::drawText(screenW / 2.0f - 130, optY + 16, sabOpts[i], Color(1, 1, 1, 1), 0.75f);
    }
    Renderer::drawText(screenW / 2.0f - 120, 460, "Use UP/DOWN & ENTER | ESC", Color(0.7f, 0.7f, 0.7f, 1.0f), 0.75f);
}

void UI::renderPauseMenu(float screenW, float screenH, int selectedOption) {
    Renderer::drawRect(screenW / 2.0f - 160, 180, 320, 360, Color(0.08f, 0.1f, 0.16f, 0.95f), true);
    Renderer::drawRect(screenW / 2.0f - 160, 180, 320, 360, Color(0.3f, 0.6f, 0.9f, 1.0f), false);

    Renderer::drawText(screenW / 2.0f - 50, 215, "PAUSED", Color(1, 1, 1, 1), 1.3f);

    std::string pauseOpts[4] = {"RESUME", "CONTROLS", "RESTART LEVEL", "MAIN MENU"};
    for (int i = 0; i < 4; ++i) {
        float optY = 270.0f + i * 55.0f;
        Color boxCol = (selectedOption == i) ? Color(0.2f, 0.5f, 0.8f, 0.9f) : Color(0.12f, 0.15f, 0.22f, 0.8f);
        Renderer::drawRect(screenW / 2.0f - 120, optY, 240, 42, boxCol, true);
        Renderer::drawRect(screenW / 2.0f - 120, optY, 240, 42, Color(0.4f, 0.7f, 1.0f, 1.0f), false);
        Renderer::drawText(screenW / 2.0f - 60, optY + 12, pauseOpts[i], Color(1, 1, 1, 1), 0.9f);
    }
}

void UI::renderEndGameScreen(float screenW, float screenH, bool crewmatesWon, const std::string& reason) {
    Color bgCol = crewmatesWon ? Color(0.05f, 0.15f, 0.08f, 0.95f) : Color(0.18f, 0.05f, 0.05f, 0.95f);
    Renderer::drawRect(0, 0, screenW, screenH, bgCol, true);

    std::string bannerTxt = crewmatesWon ? "VICTORY — CREWMATES WON!" : "DEFEAT — IMPOSTORS WON!";
    Color bannerCol = crewmatesWon ? Color(0.3f, 0.95f, 0.4f, 1.0f) : Color(0.95f, 0.2f, 0.2f, 1.0f);

    Renderer::drawText(screenW / 2.0f - 280, screenH / 2.0f - 80, bannerTxt, bannerCol, 1.5f);
    Renderer::drawText(screenW / 2.0f - 180, screenH / 2.0f, reason, Color(1, 1, 1, 1), 1.0f);

    Renderer::drawText(screenW / 2.0f - 210, screenH / 2.0f + 100, "Press ENTER to proceed to Next Level / Restart", Color(0.9f, 0.9f, 0.3f, 1.0f), 0.9f);
    Renderer::drawText(screenW / 2.0f - 140, screenH / 2.0f + 140, "Press ESC for Main Menu", Color(0.7f, 0.7f, 0.7f, 1.0f), 0.85f);
}
