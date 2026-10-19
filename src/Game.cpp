#include "Game.h"
#include "CollisionSystem.h"
#include <algorithm>
#include <iostream>
#include <cmath>

Game::Game(int width, int height)
    : state(GameState::MainMenu), previousState(GameState::MainMenu), currentLevel(1),
      screenWidth((float)width), screenHeight((float)height), selectedRole(PlayerRole::Crewmate),
      selectedMenuOption(0), selectedPauseOption(0), killBannerTimer(0.0f), killPauseTimer(0.0f),
      coordSys(width, height), map(1), showMapOverlay(false), showScoreboard(false),
      mouseClicked(false), mouseDown(false), mouseX(0), mouseY(0) {
    for (int i = 0; i < 256; ++i) keys[i] = false;
    initLevel(1, PlayerRole::Crewmate);
}

void Game::initLevel(int level, PlayerRole role) {
    currentLevel = level;
    selectedRole = role;
    map.loadLevel(level);

    killBannerTimer = 0.0f;
    killPauseTimer = 0.0f;
    killBannerText = "";
    targetBotName = "";

    // Setup Local Human Player
    localPlayer = Player(0, "Player (You)", Color(0.9f, 0.2f, 0.2f, 1.0f), role);
    localPlayer.transform.position = Vector2D(500, 250);

    // Spawn AI Players
    aiPlayers.clear();
    Color colors[8] = {
        Color(0.2f, 0.6f, 0.9f, 1.0f), // Cyan
        Color(0.2f, 0.8f, 0.3f, 1.0f), // Green
        Color(0.9f, 0.8f, 0.2f, 1.0f), // Yellow
        Color(0.7f, 0.3f, 0.9f, 1.0f), // Purple
        Color(0.9f, 0.5f, 0.2f, 1.0f), // Orange
        Color(0.3f, 0.3f, 0.3f, 1.0f), // Black
        Color(0.9f, 0.9f, 0.9f, 1.0f), // White
        Color(0.5f, 0.3f, 0.2f, 1.0f)  // Brown
    };

    int numAI = (level == 1) ? 5 : ((level == 2) ? 7 : 9);
    int numImpostors = (level == 3) ? 2 : 1;

    int aiImpostorCount = (role == PlayerRole::Impostor) ? (numImpostors - 1) : numImpostors;
    if (aiImpostorCount < 0) aiImpostorCount = 0;

    for (int i = 0; i < numAI; ++i) {
        PlayerRole aiRole = (i < aiImpostorCount) ? PlayerRole::Impostor : PlayerRole::Crewmate;
        AIPlayer ai(i + 1, "BOT " + std::to_string(i + 1), colors[i % 8], aiRole);
        ai.transform.position = Vector2D(500 + (i + 1) * 45, 250);
        aiPlayers.push_back(ai);
    }

    sabotageSys = SabotageSystem();
    meetingSys = MeetingSystem();
    showMapOverlay = false;
    showScoreboard = false;
}

bool Game::hasLineOfSight(const Vector2D& p1, const Vector2D& p2) const {
    for (const auto& wall : map.walls) {
        float minX = (std::min)(p1.x, p2.x);
        float maxX = (std::max)(p1.x, p2.x);
        float minY = (std::min)(p1.y, p2.y);
        float maxY = (std::max)(p1.y, p2.y);

        if (maxX < wall.x || minX > wall.x + wall.w || maxY < wall.y || minY > wall.y + wall.h) {
            continue;
        }
        return false;
    }
    return true;
}

void Game::handleKeyDown(unsigned char key) {
    keys[key] = true;

    // Quick Lab Shortcut (G key)
    if ((key == 'g' || key == 'G') && state == GameState::Gameplay) {
        previousState = state;
        state = GameState::GraphicsDemoMode;
        return;
    }

    if (state == GameState::MainMenu) {
        if (key == 13 || key == 32) { // ENTER / SPACE
            if (selectedMenuOption == 0) { state = GameState::Gameplay; initLevel(1, selectedRole); }
            else if (selectedMenuOption == 1) state = GameState::RoleSelection;
            else if (selectedMenuOption == 2) state = GameState::HowToPlay;
            else if (selectedMenuOption == 3) state = GameState::GraphicsDemoMode;
            else if (selectedMenuOption == 4) std::exit(0);
        } else if (key == 'w' || key == 'W' || key == 38) {
            selectedMenuOption = (selectedMenuOption - 1 + 5) % 5;
        } else if (key == 's' || key == 'S' || key == 40) {
            selectedMenuOption = (selectedMenuOption + 1) % 5;
        }

    } else if (state == GameState::RoleSelection) {
        if (key == 'w' || key == 'W' || key == 's' || key == 'S' || key == 38 || key == 40) {
            selectedRole = (selectedRole == PlayerRole::Crewmate) ? PlayerRole::Impostor : PlayerRole::Crewmate;
        } else if (key == 13 || key == 32) {
            state = GameState::Gameplay;
            initLevel(1, selectedRole);
        } else if (key == 27) state = GameState::MainMenu;

    } else if (state == GameState::HowToPlay || state == GameState::GraphicsDemoMode) {
        if (key == 27) {
            state = (previousState == GameState::Gameplay) ? GameState::Gameplay : GameState::MainMenu;
        }
        if (state == GameState::GraphicsDemoMode) graphicsDemo.handleInput(key);

    } else if (state == GameState::PauseMenu) {
        if (key == 'w' || key == 'W' || key == 38) selectedPauseOption = (selectedPauseOption - 1 + 4) % 4;
        else if (key == 's' || key == 'S' || key == 40) selectedPauseOption = (selectedPauseOption + 1) % 4;
        else if (key == 13 || key == 32) {
            if (selectedPauseOption == 0) state = GameState::Gameplay;
            else if (selectedPauseOption == 1) { previousState = GameState::Gameplay; state = GameState::HowToPlay; }
            else if (selectedPauseOption == 2) { state = GameState::Gameplay; initLevel(currentLevel, selectedRole); }
            else if (selectedPauseOption == 3) state = GameState::MainMenu;
        } else if (key == 27) state = GameState::Gameplay;

    } else if (state == GameState::SabotageMenu) {
        if (key == 'w' || key == 'W' || key == 38) selectedPauseOption = (selectedPauseOption - 1 + 3) % 3;
        else if (key == 's' || key == 'S' || key == 40) selectedPauseOption = (selectedPauseOption + 1) % 3;
        else if (key == 13 || key == 32) {
            SabotageType types[3] = {SabotageType::Lights, SabotageType::Reactor, SabotageType::Communications};
            sabotageSys.triggerSabotage(types[selectedPauseOption]);
            scoringSys.onSabotageTriggered();
            state = GameState::Gameplay;
        } else if (key == 27) state = GameState::Gameplay;

    } else if (state == GameState::Gameplay) {
        if (key == 27) { state = GameState::PauseMenu; selectedPauseOption = 0; return; }
        if (key == 'm' || key == 'M') showMapOverlay = !showMapOverlay;
        if (key == 9) showScoreboard = !showScoreboard;

        if (localPlayer.state == PlayerState::Venting) {
            if (key == 'v' || key == 'V') {
                localPlayer.state = PlayerState::Alive;
            } else if (key == 'a' || key == 'A' || key == 'd' || key == 'D') {
                Vent* v = map.getNearbyVent(localPlayer.transform.position);
                if (v != nullptr && v->connectedVentId >= 0 && v->connectedVentId < (int)map.vents.size()) {
                    localPlayer.transform.position = map.vents[v->connectedVentId].position;
                }
            }
            return;
        }

        if (key == 'e' || key == 'E') {
            if (map.isNearEmergencyButton(localPlayer.transform.position)) {
                meetingSys.startMeeting(localPlayer.id);
                state = GameState::Meeting;
                scoringSys.onEmergencyMeeting();
            } else {
                TaskSpot* t = map.getNearbyTask(localPlayer.transform.position);
                if (t != nullptr) {
                    currentTaskSpot = t;
                    TaskType type = TaskType::FixWiring;
                    if (t->taskName == "Fix Reactor") type = TaskType::FixReactor;
                    else if (t->taskName == "Fuel Engine") type = TaskType::FuelEngine;
                    else if (t->taskName == "Calibrate") type = TaskType::Calibrate;
                    else if (t->taskName == "Download Data") type = TaskType::DownloadData;
                    else if (t->taskName == "Upload Data") type = TaskType::UploadData;
                    else if (t->taskName == "Align Output") type = TaskType::AlignOutput;

                    activeMiniGame = TaskMiniGame(type);
                    state = GameState::TaskMiniGame;
                }
            }
        }

        if (key == 'r' || key == 'R') {
            for (const auto& ai : aiPlayers) {
                if (ai.state == PlayerState::Dead) {
                    float dist = std::hypot(ai.transform.position.x - localPlayer.transform.position.x,
                                            ai.transform.position.y - localPlayer.transform.position.y);
                    if (dist < 60.0f) {
                        meetingSys.startMeeting(localPlayer.id, ai.id);
                        state = GameState::Meeting;
                        scoringSys.onBodyReported();
                        break;
                    }
                }
            }
        }

        // Impostor Actions: Kill (SPACE KEY), Sabotage Menu (Q), Vent (V)
        if (localPlayer.role == PlayerRole::Impostor && localPlayer.state == PlayerState::Alive) {
            if (key == 32 && localPlayer.canKill()) { // SPACE KEY
                float minDist = 60.0f;
                int killIdx = -1;

                for (size_t i = 0; i < aiPlayers.size(); ++i) {
                    if (aiPlayers[i].state == PlayerState::Alive && aiPlayers[i].role == PlayerRole::Crewmate) {
                        float dist = std::hypot(aiPlayers[i].transform.position.x - localPlayer.transform.position.x,
                                                aiPlayers[i].transform.position.y - localPlayer.transform.position.y);
                        if (dist < minDist && hasLineOfSight(localPlayer.transform.position, aiPlayers[i].transform.position)) {
                            minDist = dist;
                            killIdx = (int)i;
                        }
                    }
                }

                if (killIdx != -1) {
                    aiPlayers[killIdx].state = PlayerState::Dead;
                    localPlayer.resetKillCooldown();
                    scoringSys.onCrewmateEliminated();

                    // Trigger Kill Showcase & Banner Notification
                    killPauseTimer = 0.8f;  // 0.8s gameplay slow/freeze
                    killBannerTimer = 2.0f; // 2.0s banner display
                    killBannerText = "YOU KILLED " + aiPlayers[killIdx].name + "!";
                    killBurstPos = aiPlayers[killIdx].transform.position;
                }

            } else if (key == 'v' || key == 'V') {
                Vent* vent = map.getNearbyVent(localPlayer.transform.position);
                if (vent != nullptr) {
                    localPlayer.state = PlayerState::Venting;
                    scoringSys.onVentUsed();
                }
            } else if (key == 'q' || key == 'Q') {
                state = GameState::SabotageMenu;
                selectedPauseOption = 0;
            }
        }

    } else if (state == GameState::TaskMiniGame) {
        if (key == 27 || key == 'x' || key == 'X') state = GameState::Gameplay;

    } else if (state == GameState::Victory || state == GameState::Defeat) {
        if (key == 13 || key == 32) {
            if (currentLevel < 3 && state == GameState::Victory) {
                initLevel(currentLevel + 1, selectedRole);
                state = GameState::Gameplay;
            } else {
                initLevel(1, selectedRole);
                state = GameState::Gameplay;
            }
        } else if (key == 27) state = GameState::MainMenu;
    }
}

void Game::handleKeyUp(unsigned char key) {
    keys[key] = false;
}

void Game::handleMouseMove(float x, float y) {
    mouseX = x;
    mouseY = y;
}

void Game::handleMouseClick(float x, float y, bool down) {
    mouseX = x;
    mouseY = y;
    mouseDown = down;
    if (down) mouseClicked = true;
}

void Game::update(float deltaTime) {
    // Update Kill Timers
    if (killBannerTimer > 0.0f) {
        killBannerTimer -= deltaTime;
        if (killBannerTimer < 0.0f) killBannerTimer = 0.0f;
    }
    if (killPauseTimer > 0.0f) {
        killPauseTimer -= deltaTime;
        if (killPauseTimer < 0.0f) killPauseTimer = 0.0f;
        return; // Momentary freeze frame on kill showcase
    }

    if (state == GameState::Gameplay) {
        // Calculate Target Crewmate in Range for Contextual HUD Feedback
        targetBotName = "";
        if (localPlayer.role == PlayerRole::Impostor && localPlayer.state == PlayerState::Alive && localPlayer.canKill()) {
            float minDist = 60.0f;
            for (const auto& ai : aiPlayers) {
                if (ai.state == PlayerState::Alive && ai.role == PlayerRole::Crewmate) {
                    float dist = std::hypot(ai.transform.position.x - localPlayer.transform.position.x,
                                            ai.transform.position.y - localPlayer.transform.position.y);
                    if (dist < minDist && hasLineOfSight(localPlayer.transform.position, ai.transform.position)) {
                        minDist = dist;
                        targetBotName = ai.name;
                    }
                }
            }
        }

        if (localPlayer.state != PlayerState::Venting) {
            localPlayer.velocity = Vector2D(0, 0);
            if (keys['w'] || keys['W'] || keys[38]) localPlayer.velocity.y -= 1.0f;
            if (keys['s'] || keys['S'] || keys[40]) localPlayer.velocity.y += 1.0f;
            if (keys['a'] || keys['A'] || keys[37]) localPlayer.velocity.x -= 1.0f;
            if (keys['d'] || keys['D'] || keys[39]) localPlayer.velocity.x += 1.0f;

            localPlayer.update(deltaTime);
            localPlayer.transform.position = CollisionSystem::resolveMapCollisions(
                localPlayer.transform.position.x, localPlayer.transform.position.y, 16.0f, map.walls);
        }

        coordSys.cameraPos = localPlayer.transform.position;

        allPlayersCache.clear();
        allPlayersCache.push_back(localPlayer);
        for (const auto& ai : aiPlayers) allPlayersCache.push_back(ai);

        std::vector<Vector2D> taskLocs;
        for (const auto& t : map.taskSpots) taskLocs.push_back(t.position);

        for (auto& ai : aiPlayers) {
            ai.updateAI(deltaTime, map.waypoints, taskLocs, allPlayersCache);
            ai.transform.position = CollisionSystem::resolveMapCollisions(
                ai.transform.position.x, ai.transform.position.y, 16.0f, map.walls);
        }

        sabotageSys.update(deltaTime);
        map.update(deltaTime);
        checkWinConditions();

    } else if (state == GameState::TaskMiniGame) {
        activeMiniGame.update(deltaTime, mouseX, mouseY, mouseClicked, mouseDown);
        mouseClicked = false;

        if (activeMiniGame.isFinished && currentTaskSpot != nullptr) {
            currentTaskSpot->isCompleted = true;
            scoringSys.onTaskCompleted();
            state = GameState::Gameplay;
        }

    } else if (state == GameState::Meeting) {
        allPlayersCache.clear();
        allPlayersCache.push_back(localPlayer);
        for (const auto& ai : aiPlayers) allPlayersCache.push_back(ai);

        meetingSys.update(deltaTime, allPlayersCache);

        localPlayer = allPlayersCache[0];
        for (size_t i = 0; i < aiPlayers.size(); ++i) {
            aiPlayers[i] = AIPlayer(allPlayersCache[i + 1].id, allPlayersCache[i + 1].name,
                                    allPlayersCache[i + 1].color, allPlayersCache[i + 1].role);
            aiPlayers[i].state = allPlayersCache[i + 1].state;
            aiPlayers[i].transform = allPlayersCache[i + 1].transform;
        }

        if (meetingSys.state == MeetingState::Finished) {
            state = GameState::Gameplay;
            checkWinConditions();
        }

    } else if (state == GameState::GraphicsDemoMode) {
        graphicsDemo.update(deltaTime);
    }
}

void Game::checkWinConditions() {
    int totalTasks = (int)map.taskSpots.size();
    int completedTasks = 0;
    for (const auto& t : map.taskSpots) {
        if (t.isCompleted) completedTasks++;
    }

    int aliveCrewmates = 0;
    int aliveImpostors = 0;

    if (localPlayer.state == PlayerState::Alive) {
        if (localPlayer.role == PlayerRole::Crewmate) aliveCrewmates++;
        else aliveImpostors++;
    }
    for (const auto& ai : aiPlayers) {
        if (ai.state == PlayerState::Alive) {
            if (ai.role == PlayerRole::Crewmate) aliveCrewmates++;
            else aliveImpostors++;
        }
    }

    if (completedTasks == totalTasks && totalTasks > 0) {
        scoringSys.onAllTasksCompleted();
        state = GameState::Victory;
    } else if (aliveImpostors == 0) {
        state = GameState::Victory;
    } else if (aliveImpostors >= aliveCrewmates) {
        state = GameState::Defeat;
    } else if (sabotageSys.isCriticalFailure()) {
        state = GameState::Defeat;
    }
}

void Game::render() {
    if (state == GameState::MainMenu) {
        UI::renderMainMenu(screenWidth, screenHeight, selectedMenuOption);
    } else if (state == GameState::RoleSelection) {
        UI::renderRoleSelection(screenWidth, screenHeight, selectedRole);
    } else if (state == GameState::HowToPlay) {
        UI::renderHowToPlay(screenWidth, screenHeight);
    } else if (state == GameState::GraphicsDemoMode) {
        graphicsDemo.render(screenWidth, screenHeight);
    } else if (state == GameState::Gameplay || state == GameState::TaskMiniGame ||
               state == GameState::Meeting || state == GameState::SabotageMenu || state == GameState::PauseMenu) {
        Renderer::clear(Color(0.04f, 0.05f, 0.08f, 1.0f));

        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();

        Vector2D camOffset = coordSys.worldToScreen(Vector2D(0, 0));
        glTranslatef(camOffset.x, camOffset.y, 0.0f);

        map.render();

        // Render Dead Bodies
        for (const auto& ai : aiPlayers) {
            if (ai.state == PlayerState::Dead) {
                Renderer::drawDeadBody(ai.transform.position.x, ai.transform.position.y, ai.color);
            }
        }

        // Render Kill Burst Particles
        if (killPauseTimer > 0.0f || killBannerTimer > 1.2f) {
            Renderer::drawKillBurst(killBurstPos.x, killBurstPos.y, (2.0f - killBannerTimer));
        }

        // Render Living Players
        for (const auto& ai : aiPlayers) {
            if (ai.state == PlayerState::Alive) ai.render();
        }
        if (localPlayer.state == PlayerState::Alive) localPlayer.render();

        if (sabotageSys.activeSabotage == SabotageType::Lights) {
            Renderer::drawDarknessFOV(localPlayer.transform.position.x, localPlayer.transform.position.y, 180.0f, screenWidth, screenHeight);
        }

        glLoadIdentity();

        float taskProgress = map.taskSpots.empty() ? 0.0f : 0.0f;
        int completed = 0;
        for (const auto& t : map.taskSpots) if (t.isCompleted) completed++;
        if (!map.taskSpots.empty()) taskProgress = (float)completed / map.taskSpots.size();

        bool isNearTask = (map.getNearbyTask(localPlayer.transform.position) != nullptr);
        bool isNearBody = false;
        for (const auto& ai : aiPlayers) {
            if (ai.state == PlayerState::Dead && std::hypot(ai.transform.position.x - localPlayer.transform.position.x, ai.transform.position.y - localPlayer.transform.position.y) < 60.0f) {
                isNearBody = true; break;
            }
        }
        bool isNearVent = (map.getNearbyVent(localPlayer.transform.position) != nullptr);
        bool isNearEmerg = map.isNearEmergencyButton(localPlayer.transform.position);

        UI::renderHUD(screenWidth, screenHeight, localPlayer, map, taskProgress, isNearTask, isNearBody, isNearVent, isNearEmerg, targetBotName, showMapOverlay);
        sabotageSys.renderUI(screenWidth, screenHeight);
        scoringSys.renderScoreboard(screenWidth, screenHeight, showScoreboard);

        // Render Kill Banner Notification (YOU KILLED BOT X!)
        if (killBannerTimer > 0.0f) {
            Renderer::drawKillBanner(screenWidth, screenHeight, killBannerText);
        }

        if (state == GameState::TaskMiniGame) activeMiniGame.render(screenWidth, screenHeight);
        if (state == GameState::SabotageMenu) UI::renderSabotageMenu(screenWidth, screenHeight, selectedPauseOption);
        if (state == GameState::PauseMenu) UI::renderPauseMenu(screenWidth, screenHeight, selectedPauseOption);

        if (state == GameState::Meeting) {
            allPlayersCache.clear();
            allPlayersCache.push_back(localPlayer);
            for (const auto& ai : aiPlayers) allPlayersCache.push_back(ai);
            meetingSys.renderUI(screenWidth, screenHeight, allPlayersCache, localPlayer.id);
        }

    } else if (state == GameState::Victory) {
        UI::renderEndGameScreen(screenWidth, screenHeight, true, "Crewmates Completed Objectives!");
    } else if (state == GameState::Defeat) {
        UI::renderEndGameScreen(screenWidth, screenHeight, false, "Impostors Overwhelmed Station!");
    }
}
