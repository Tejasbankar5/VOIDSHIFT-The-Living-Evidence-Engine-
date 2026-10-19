#ifndef AI_PLAYER_H
#define AI_PLAYER_H

#include "Player.h"
#include <vector>

enum class AIState {
    Wandering,
    MovingToTask,
    PerformingTask,
    StalkingTarget,
    Fleeing,
    FixingSabotage
};

class AIPlayer : public Player {
public:
    AIState aiState;
    Vector2D targetWaypoint;
    float stateTimer;
    int currentTaskIndex;
    int suspectPlayerId; // Suspicion target for voting

    AIPlayer(int _id, const std::string& _name, Color _color, PlayerRole _role);

    void updateAI(float deltaTime, const std::vector<Vector2D>& roomWaypoints,
                  const std::vector<Vector2D>& taskLocations, std::vector<Player>& allPlayers);
};

#endif // AI_PLAYER_H
