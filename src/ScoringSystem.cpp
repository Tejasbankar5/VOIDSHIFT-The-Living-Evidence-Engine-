#include "ScoringSystem.h"

ScoringSystem::ScoringSystem() : crewmateScore(0), impostorScore(0) {}

void ScoringSystem::onTaskCompleted()       { crewmateScore += 10; }
void ScoringSystem::onAllTasksCompleted()   { crewmateScore += 50; }
void ScoringSystem::onBodyReported()         { crewmateScore += 15; }
void ScoringSystem::onEmergencyMeeting()     { crewmateScore += 10; }
void ScoringSystem::onCrewmateSurvived()     { crewmateScore += 25; }

void ScoringSystem::onCrewmateEliminated()   { impostorScore += 50; }
void ScoringSystem::onSabotageTriggered()   { impostorScore += 25; }
void ScoringSystem::onVentUsed()            { impostorScore += 10; }
void ScoringSystem::onRemainUndetected()    { impostorScore += 75; }
void ScoringSystem::onTaskDisrupted()       { impostorScore += 20; }

void ScoringSystem::renderScoreboard(float screenW, float screenH, bool showFull) const {
    if (!showFull) {
        // Top right mini score indicator
        Renderer::drawRect(screenW - 220, 15, 205, 55, Color(0.1f, 0.12f, 0.18f, 0.85f), true);
        Renderer::drawRect(screenW - 220, 15, 205, 55, Color(0.3f, 0.5f, 0.7f, 1.0f), false);
        Renderer::drawText(screenW - 205, 25, "CREWMATE SCORE: " + std::to_string(crewmateScore), Color(0.4f, 0.9f, 0.4f, 1.0f), 0.75f);
        Renderer::drawText(screenW - 205, 45, "IMPOSTOR SCORE: " + std::to_string(impostorScore), Color(0.9f, 0.3f, 0.3f, 1.0f), 0.75f);
    } else {
        // Full Scoreboard Dialog
        Renderer::drawRect(screenW / 2.0f - 250, 140, 500, 440, Color(0.08f, 0.1f, 0.16f, 0.95f), true);
        Renderer::drawRect(screenW / 2.0f - 250, 140, 500, 440, Color(0.4f, 0.7f, 0.9f, 1.0f), false);
        Renderer::drawText(screenW / 2.0f - 140, 170, "ACADEMIC SCOREBOARD", Color(1, 1, 1, 1), 1.2f);

        Renderer::drawText(screenW / 2.0f - 210, 230, "Crewmate Actions:", Color(0.4f, 0.9f, 0.4f, 1.0f), 0.9f);
        Renderer::drawText(screenW / 2.0f - 190, 260, "Task Complete: +10 | All Tasks: +50", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);
        Renderer::drawText(screenW / 2.0f - 190, 285, "Report Body: +15 | Emergency: +10", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);
        Renderer::drawText(screenW / 2.0f - 190, 310, "Total Crewmate Score: " + std::to_string(crewmateScore), Color(0.4f, 0.9f, 0.4f, 1.0f), 1.0f);

        Renderer::drawText(screenW / 2.0f - 210, 360, "Impostor Actions:", Color(0.9f, 0.3f, 0.3f, 1.0f), 0.9f);
        Renderer::drawText(screenW / 2.0f - 190, 390, "Eliminate Crewmate: +50 | Sabotage: +25", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);
        Renderer::drawText(screenW / 2.0f - 190, 415, "Vent Use: +10 | Undetected: +75", Color(0.8f, 0.8f, 0.8f, 1.0f), 0.75f);
        Renderer::drawText(screenW / 2.0f - 190, 440, "Total Impostor Score: " + std::to_string(impostorScore), Color(0.9f, 0.3f, 0.3f, 1.0f), 1.0f);

        Renderer::drawText(screenW / 2.0f - 120, 520, "Press TAB to close", Color(0.6f, 0.6f, 0.6f, 1.0f), 0.8f);
    }
}
