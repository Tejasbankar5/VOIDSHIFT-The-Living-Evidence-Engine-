#include "AIPlayer.h"
#include <cstdlib>
#include <cmath>

AIPlayer::AIPlayer(int _id, const std::string& _name, Color _color, PlayerRole _role)
    : Player(_id, _name, _color, _role), aiState(AIState::Wandering),
      targetWaypoint(0.0f, 0.0f), stateTimer(0.0f), currentTaskIndex(0), suspectPlayerId(-1) {}

void AIPlayer::updateAI(float deltaTime, const std::vector<Vector2D>& roomWaypoints,
                        const std::vector<Vector2D>& taskLocations, std::vector<Player>& allPlayers) {
    if (state == PlayerState::Dead || state == PlayerState::InMeeting) return;

    stateTimer -= deltaTime;

    // AI Waypoint movement logic
    Vector2D dir = Vector2D(targetWaypoint.x - transform.position.x, targetWaypoint.y - transform.position.y);
    float dist = std::sqrt(dir.x * dir.x + dir.y * dir.y);

    if (dist < 15.0f || stateTimer <= 0.0f) {
        // Pick next destination
        if (role == PlayerRole::Crewmate) {
            if (taskLocations.empty() || (std::rand() % 100 < 40)) {
                aiState = AIState::Wandering;
                if (!roomWaypoints.empty()) {
                    targetWaypoint = roomWaypoints[std::rand() % roomWaypoints.size()];
                }
            } else {
                aiState = AIState::MovingToTask;
                targetWaypoint = taskLocations[std::rand() % taskLocations.size()];
            }
        } else { // Impostor AI
            aiState = AIState::StalkingTarget;
            // Target closest living Crewmate
            float minDist = 9999.0f;
            int targetIdx = -1;
            for (size_t i = 0; i < allPlayers.size(); ++i) {
                if (allPlayers[i].id != id && allPlayers[i].state == PlayerState::Alive && allPlayers[i].role == PlayerRole::Crewmate) {
                    float d = std::hypot(allPlayers[i].transform.position.x - transform.position.x,
                                         allPlayers[i].transform.position.y - transform.position.y);
                    if (d < minDist) {
                        minDist = d;
                        targetIdx = (int)i;
                    }
                }
            }
            if (targetIdx != -1) {
                targetWaypoint = allPlayers[targetIdx].transform.position;
                // Impostor kill execution when close and off cooldown
                if (minDist < 45.0f && canKill()) {
                    allPlayers[targetIdx].state = PlayerState::Dead;
                    resetKillCooldown();
                    score += 50; // PPT Impostor Kill Score
                }
            } else if (!roomWaypoints.empty()) {
                targetWaypoint = roomWaypoints[std::rand() % roomWaypoints.size()];
            }
        }
        stateTimer = 5.0f + (std::rand() % 5);
    }

    // Update velocity towards target waypoint
    dir = Vector2D(targetWaypoint.x - transform.position.x, targetWaypoint.y - transform.position.y);
    dist = std::sqrt(dir.x * dir.x + dir.y * dir.y);
    if (dist > 0.1f) {
        velocity.x = dir.x / dist;
        velocity.y = dir.y / dist;
    } else {
        velocity = Vector2D(0, 0);
    }

    update(deltaTime);
}
