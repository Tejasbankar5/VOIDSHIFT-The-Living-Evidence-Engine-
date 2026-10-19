#ifndef SCORING_SYSTEM_H
#define SCORING_SYSTEM_H

#include "Renderer.h"
#include <string>

class ScoringSystem {
public:
    int crewmateScore;
    int impostorScore;

    ScoringSystem();

    // Crewmate Scoring Actions (PPT Table)
    void onTaskCompleted();      // +10
    void onAllTasksCompleted();   // +50
    void onBodyReported();       // +15
    void onEmergencyMeeting();   // +10
    void onCrewmateSurvived();   // +25

    // Impostor Scoring Actions (PPT Table)
    void onCrewmateEliminated();  // +50
    void onSabotageTriggered();  // +25
    void onVentUsed();           // +10
    void onRemainUndetected();   // +75
    void onTaskDisrupted();      // +20

    void renderScoreboard(float screenW, float screenH, bool showFull = false) const;
};

#endif // SCORING_SYSTEM_H
