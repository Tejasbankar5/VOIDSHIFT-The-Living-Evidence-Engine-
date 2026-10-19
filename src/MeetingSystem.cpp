#include "MeetingSystem.h"
#include <map>
#include <cstdlib>

MeetingSystem::MeetingSystem()
    : state(MeetingState::Finished), stateTimer(0.0f), reporterId(-1),
      reportedBodyId(-1), ejectedPlayerId(-2), isEjectedImpostor(false) {}

void MeetingSystem::startMeeting(int _reporterId, int _reportedBodyId) {
    state = MeetingState::Discussion;
    stateTimer = 5.0f; // 5 seconds discussion
    reporterId = _reporterId;
    reportedBodyId = _reportedBodyId;
    votes.clear();
    ejectedPlayerId = -2;
    isEjectedImpostor = false;
}

void MeetingSystem::castVote(int voterId, int targetId) {
    for (const auto& v : votes) {
        if (v.voterId == voterId) return; // Already voted
    }
    votes.push_back({voterId, targetId});
}

void MeetingSystem::processAIVotes(const std::vector<Player>& players) {
    for (const auto& p : players) {
        if (p.id == 0) continue; // Skip local human player
        if (p.state == PlayerState::Dead) continue;

        bool alreadyVoted = false;
        for (const auto& v : votes) {
            if (v.voterId == p.id) { alreadyVoted = true; break; }
        }
        if (alreadyVoted) continue;

        // AI Suspicion Logic
        int target = -1; // Default skip
        std::vector<int> suspectCandidates;
        for (const auto& other : players) {
            if (other.id != p.id && other.state == PlayerState::Alive) {
                suspectCandidates.push_back(other.id);
            }
        }
        if (!suspectCandidates.empty() && (std::rand() % 100 < 70)) {
            target = suspectCandidates[std::rand() % suspectCandidates.size()];
        }
        castVote(p.id, target);
    }
}

void MeetingSystem::calculateResults(std::vector<Player>& players) {
    std::map<int, int> voteCounts; // targetId -> count
    for (const auto& v : votes) {
        voteCounts[v.targetId]++;
    }

    int maxVotes = 0;
    int winnerId = -1;
    bool tie = false;

    for (const auto& pair : voteCounts) {
        if (pair.second > maxVotes) {
            maxVotes = pair.second;
            winnerId = pair.first;
            tie = false;
        } else if (pair.second == maxVotes) {
            tie = true;
        }
    }

    if (tie || winnerId == -1) {
        ejectedPlayerId = -1; // Tied / Skipped
    } else {
        ejectedPlayerId = winnerId;
        for (auto& p : players) {
            if (p.id == winnerId) {
                p.state = PlayerState::Dead;
                isEjectedImpostor = (p.role == PlayerRole::Impostor);
                break;
            }
        }
    }
}

void MeetingSystem::update(float deltaTime, std::vector<Player>& players) {
    if (state == MeetingState::Finished) return;

    stateTimer -= deltaTime;

    if (state == MeetingState::Discussion) {
        if (stateTimer <= 0.0f) {
            state = MeetingState::Voting;
            stateTimer = 15.0f; // 15 seconds voting phase
        }
    } else if (state == MeetingState::Voting) {
        processAIVotes(players);
        if (stateTimer <= 0.0f || votes.size() >= players.size()) {
            calculateResults(players);
            state = MeetingState::EjectionAnimation;
            stateTimer = 4.0f; // 4 seconds ejection screen
        }
    } else if (state == MeetingState::EjectionAnimation) {
        if (stateTimer <= 0.0f) {
            state = MeetingState::Finished;
        }
    }
}

void MeetingSystem::renderUI(float screenW, float screenH, const std::vector<Player>& players, int localPlayerId) const {
    if (state == MeetingState::Finished) return;

    if (state == MeetingState::Discussion || state == MeetingState::Voting) {
        // Meeting Overlay Panel
        Renderer::drawRect(180, 80, 920, 560, Color(0.08f, 0.12f, 0.18f, 0.96f), true);
        Renderer::drawRect(180, 80, 920, 560, Color(0.9f, 0.3f, 0.3f, 1.0f), false);

        std::string titleStr = (state == MeetingState::Discussion) ? "EMERGENCY DISCUSSION" : "VOTING IN PROGRESS";
        Renderer::drawText(220, 110, titleStr, Color(1, 1, 1, 1), 1.3f);

        std::string timerStr = "Time Remaining: " + std::to_string((int)stateTimer) + "s";
        Renderer::drawText(820, 110, timerStr, Color(0.9f, 0.9f, 0.3f, 1.0f), 0.9f);

        // Player Cards List
        float startY = 170.0f;
        for (size_t i = 0; i < players.size(); ++i) {
            float cardY = startY + i * 52.0f;
            Color cardBg = (players[i].state == PlayerState::Dead) ? Color(0.2f, 0.2f, 0.2f, 0.8f) : Color(0.18f, 0.22f, 0.3f, 1.0f);
            Renderer::drawRect(220, cardY, 600, 44, cardBg, true);
            Renderer::drawCircle(250, cardY + 22, 14.0f, players[i].color, true);
            Renderer::drawText(280, cardY + 14, players[i].name, Color(1, 1, 1, 1), 1.0f);

            if (players[i].state == PlayerState::Dead) {
                Renderer::drawText(680, cardY + 14, "[DEAD]", Color(0.9f, 0.2f, 0.2f, 1.0f), 0.9f);
            }

            // Vote Button for Local Player
            if (state == MeetingState::Voting && localPlayerId == 0 && players[0].state == PlayerState::Alive && players[i].state == PlayerState::Alive) {
                Renderer::drawRect(750, cardY + 6, 60, 32, Color(0.2f, 0.8f, 0.4f, 1.0f), true);
                Renderer::drawText(762, cardY + 14, "VOTE", Color(1, 1, 1, 1), 0.8f);
            }
        }

        // Skip Vote Button
        if (state == MeetingState::Voting && localPlayerId == 0 && players[0].state == PlayerState::Alive) {
            Renderer::drawRect(840, 560, 200, 45, Color(0.4f, 0.45f, 0.55f, 1.0f), true);
            Renderer::drawText(880, 575, "SKIP VOTE", Color(1, 1, 1, 1), 1.0f);
        }

    } else if (state == MeetingState::EjectionAnimation) {
        // Ejection Outer Space Screen
        Renderer::drawRect(0, 0, screenW, screenH, Color(0.02f, 0.04f, 0.08f, 1.0f), true);

        // Stars background
        for (int i = 0; i < 50; ++i) {
            float sx = (i * 137) % (int)screenW;
            float sy = (i * 269) % (int)screenH;
            Renderer::drawPoint(sx, sy, Color(1, 1, 1, 0.8f), 2.0f);
        }

        if (ejectedPlayerId == -1) {
            Renderer::drawText(screenW / 2.0f - 220, screenH / 2.0f, "No one was ejected. (Skipped/Tied)", Color(1, 1, 1, 1), 1.2f);
        } else {
            std::string pName = "Player";
            for (const auto& p : players) {
                if (p.id == ejectedPlayerId) { pName = p.name; break; }
            }

            // Floating matrix rotated ejected character
            float floatX = screenW * (1.0f - (stateTimer / 4.0f));
            Transform ejectTrans(floatX, screenH / 2.0f - 40.0f, 1.5f, 1.5f, (4.0f - stateTimer) * 3.0f);
            Renderer::drawCrewmate(ejectTrans, Color(0.9f, 0.2f, 0.2f, 1.0f), false, 0.0f, false);

            std::string revealStr = pName + (isEjectedImpostor ? " was An Impostor." : " was NOT An Impostor.");
            Renderer::drawText(screenW / 2.0f - 260, screenH / 2.0f + 60.0f, revealStr, Color(1, 1, 1, 1), 1.3f);
        }
    }
}
