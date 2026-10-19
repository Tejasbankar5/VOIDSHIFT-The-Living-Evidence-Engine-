#ifndef GAME_H
#define GAME_H

#include <vector>
#include <string>
#include "Player.h"
#include "AIPlayer.h"
#include "Map.h"
#include "Task.h"
#include "SabotageSystem.h"
#include "MeetingSystem.h"
#include "ScoringSystem.h"
#include "CoordinateSystem.h"
#include "UI.h"
#include "GraphicsDemo.h"

enum class GameState {
    MainMenu,
    RoleSelection,
    HowToPlay,
    Gameplay,
    TaskMiniGame,
    Meeting,
    SabotageMenu,
    PauseMenu,
    Victory,
    Defeat,
    GraphicsDemoMode
};

class Game {
public:
    GameState state;
    GameState previousState;
    int currentLevel;
    float screenWidth;
    float screenHeight;

    PlayerRole selectedRole;
    int selectedMenuOption;
    int selectedPauseOption;

    // Kill Presentation State
    float killBannerTimer;
    float killPauseTimer;
    std::string killBannerText;
    Vector2D killBurstPos;
    std::string targetBotName;

    CoordinateSystem coordSys;
    Map map;
    Player localPlayer;
    std::vector<AIPlayer> aiPlayers;
    std::vector<Player> allPlayersCache;

    SabotageSystem sabotageSys;
    MeetingSystem meetingSys;
    ScoringSystem scoringSys;
    GraphicsDemo graphicsDemo;

    TaskMiniGame activeMiniGame;
    TaskSpot* currentTaskSpot;

    bool showMapOverlay;
    bool showScoreboard;

    // Input States
    bool keys[256];
    bool mouseClicked;
    bool mouseDown;
    float mouseX, mouseY;

    Game(int width = 1280, int height = 720);

    void initLevel(int level, PlayerRole role);
    void handleKeyDown(unsigned char key);
    void handleKeyUp(unsigned char key);
    void handleMouseMove(float x, float y);
    void handleMouseClick(float x, float y, bool down);

    void update(float deltaTime);
    void render();

    bool hasLineOfSight(const Vector2D& p1, const Vector2D& p2) const;
    void checkWinConditions();
};

#endif // GAME_H
