#ifndef PLAYER_H
#define PLAYER_H

#include <string>
#include "Transform.h"
#include "Renderer.h"

enum class PlayerRole {
    Crewmate,
    Impostor
};

enum class PlayerState {
    Alive,
    Dead,
    Venting,
    InTask,
    InMeeting
};

class Player {
public:
    int id;
    std::string name;
    Color color;
    PlayerRole role;
    PlayerState state;
    Transform transform;
    Vector2D velocity;
    float speed;

    bool isFacingLeft;
    float walkAnimTimer;

    // Impostor attributes
    float killCooldown;
    float maxKillCooldown;
    int currentVentId;

    // Crewmate score & stats
    int score;
    int tasksCompleted;
    int totalTasksAssigned;

    Player(int _id = 0, const std::string& _name = "Player", Color _color = Color(1, 0, 0, 1), PlayerRole _role = PlayerRole::Crewmate);

    void update(float deltaTime);
    void render() const;

    bool canKill() const;
    void resetKillCooldown();
};

#endif // PLAYER_H
