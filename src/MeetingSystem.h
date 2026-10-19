#ifndef MEETING_SYSTEM_H
#define MEETING_SYSTEM_H

#include <vector>
#include <string>
#include "Player.h"
#include "Renderer.h"

enum class MeetingState {
    Discussion,
    Voting,
    EjectionAnimation,
    Finished
};

struct VoteRecord {
    int voterId;
    int targetId; // -1 for Skip
};

class MeetingSystem {
public:
    MeetingState state;
    float stateTimer;
    int reporterId;
    int reportedBodyId;
    std::vector<VoteRecord> votes;
    int ejectedPlayerId;
    bool isEjectedImpostor;

    MeetingSystem();

    void startMeeting(int _reporterId, int _reportedBodyId = -1);
    void update(float deltaTime, std::vector<Player>& players);
    void castVote(int voterId, int targetId);
    void processAIVotes(const std::vector<Player>& players);
    void calculateResults(std::vector<Player>& players);

    void renderUI(float screenW, float screenH, const std::vector<Player>& players, int localPlayerId) const;
};

#endif // MEETING_SYSTEM_H
