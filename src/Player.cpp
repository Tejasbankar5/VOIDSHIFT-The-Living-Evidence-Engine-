#include "Player.h"
#include <cmath>

Player::Player(int _id, const std::string& _name, Color _color, PlayerRole _role)
    : id(_id), name(_name), color(_color), role(_role), state(PlayerState::Alive),
      transform(0.0f, 0.0f, 1.0f, 1.0f, 0.0f), velocity(0.0f, 0.0f), speed(220.0f),
      isFacingLeft(false), walkAnimTimer(0.0f), killCooldown(15.0f), maxKillCooldown(15.0f),
      currentVentId(-1), score(0), tasksCompleted(0), totalTasksAssigned(4) {}

void Player::update(float deltaTime) {
    if (state == PlayerState::Dead) return;

    if (role == PlayerRole::Impostor && killCooldown > 0.0f) {
        killCooldown -= deltaTime;
        if (killCooldown < 0.0f) killCooldown = 0.0f;
    }

    if (velocity.x != 0.0f || velocity.y != 0.0f) {
        walkAnimTimer += deltaTime;
        if (velocity.x < 0.0f) isFacingLeft = true;
        else if (velocity.x > 0.0f) isFacingLeft = false;

        transform.position.x += velocity.x * speed * deltaTime;
        transform.position.y += velocity.y * speed * deltaTime;
    } else {
        walkAnimTimer = 0.0f;
    }
}

void Player::render() const {
    if (state == PlayerState::Venting) return;

    Renderer::drawCrewmate(transform, color, state == PlayerState::Dead, walkAnimTimer, isFacingLeft, id == 0);

    Color textColor = (role == PlayerRole::Impostor && state == PlayerState::Alive && id == 0) ? Color(1.0f, 0.2f, 0.2f, 1.0f) : Color(1.0f, 1.0f, 1.0f, 1.0f);
    Renderer::drawText(transform.position.x - 24.0f, transform.position.y - 35.0f, name, textColor, 0.8f);
}

bool Player::canKill() const {
    return (role == PlayerRole::Impostor && state == PlayerState::Alive && killCooldown <= 0.0f);
}

void Player::resetKillCooldown() {
    killCooldown = maxKillCooldown;
}
