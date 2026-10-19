#include "Map.h"
#include "Renderer.h"

Map::Map(int level) : cctvAnimTime(0.0f) {
    loadLevel(level);
}

void Map::loadLevel(int level) {
    levelNumber = level;
    cctvAnimTime = 0.0f;
    rooms.clear();
    walls.clear();
    vents.clear();
    taskSpots.clear();
    waypoints.clear();
    cctvPositions.clear();

    if (level == 1) {
        stationName = "Level 1 - Training Station";
        rooms.push_back({"Cafeteria", RectBounds(400, 100, 400, 300), Color(0.12f, 0.16f, 0.22f, 1.0f)});
        rooms.push_back({"Admin", RectBounds(900, 150, 300, 200), Color(0.15f, 0.14f, 0.22f, 1.0f)});
        rooms.push_back({"Electrical", RectBounds(100, 100, 250, 250), Color(0.2f, 0.18f, 0.12f, 1.0f)});
        rooms.push_back({"MedBay", RectBounds(100, 420, 250, 220), Color(0.12f, 0.22f, 0.2f, 1.0f)});
        rooms.push_back({"Reactor", RectBounds(400, 470, 300, 200), Color(0.22f, 0.12f, 0.12f, 1.0f)});
        rooms.push_back({"Navigation", RectBounds(800, 420, 300, 220), Color(0.14f, 0.18f, 0.25f, 1.0f)});

        emergencyButtonPos = Vector2D(600, 250);

        vents.push_back({0, Vector2D(450, 150), 1});
        vents.push_back({1, Vector2D(950, 180), 0});
        vents.push_back({2, Vector2D(150, 150), 3});
        vents.push_back({3, Vector2D(450, 520), 2});

        taskSpots.push_back({0, "Fix Wiring", "Electrical", Vector2D(180, 140), false});
        taskSpots.push_back({1, "Download Data", "Cafeteria", Vector2D(700, 140), false});
        taskSpots.push_back({2, "Upload Data", "Admin", Vector2D(1050, 220), false});
        taskSpots.push_back({3, "Fix Reactor", "Reactor", Vector2D(480, 540), false});

        // CCTV Security Cameras
        cctvPositions.push_back(Vector2D(420, 120)); // Cafeteria Camera
        cctvPositions.push_back(Vector2D(820, 440)); // Navigation Camera
        cctvPositions.push_back(Vector2D(120, 120)); // Electrical Camera

        walls.push_back(RectBounds(80, 80, 1140, 20));
        walls.push_back(RectBounds(80, 680, 1140, 20));
        walls.push_back(RectBounds(80, 80, 20, 620));
        walls.push_back(RectBounds(1200, 80, 20, 620));

        walls.push_back(RectBounds(350, 100, 50, 200));
        walls.push_back(RectBounds(350, 420, 50, 250));
        walls.push_back(RectBounds(700, 420, 100, 250));

    } else if (level == 2) {
        stationName = "Level 2 - Research Station";
        rooms.push_back({"Cafeteria", RectBounds(400, 100, 400, 300), Color(0.12f, 0.16f, 0.22f, 1.0f)});
        rooms.push_back({"Admin", RectBounds(900, 150, 300, 200), Color(0.15f, 0.14f, 0.22f, 1.0f)});
        rooms.push_back({"Electrical", RectBounds(100, 100, 250, 250), Color(0.2f, 0.18f, 0.12f, 1.0f)});
        rooms.push_back({"MedBay", RectBounds(100, 420, 250, 220), Color(0.12f, 0.22f, 0.2f, 1.0f)});
        rooms.push_back({"Reactor", RectBounds(400, 470, 300, 200), Color(0.22f, 0.12f, 0.12f, 1.0f)});
        rooms.push_back({"Navigation", RectBounds(800, 420, 300, 220), Color(0.14f, 0.18f, 0.25f, 1.0f)});
        rooms.push_back({"Security", RectBounds(1250, 150, 250, 250), Color(0.18f, 0.15f, 0.22f, 1.0f)});
        rooms.push_back({"Storage", RectBounds(1250, 430, 250, 240), Color(0.22f, 0.2f, 0.14f, 1.0f)});

        emergencyButtonPos = Vector2D(600, 250);

        vents.push_back({0, Vector2D(450, 150), 1});
        vents.push_back({1, Vector2D(950, 180), 4});
        vents.push_back({2, Vector2D(150, 150), 3});
        vents.push_back({3, Vector2D(450, 520), 2});
        vents.push_back({4, Vector2D(1350, 200), 1});

        taskSpots.push_back({0, "Fix Wiring", "Electrical", Vector2D(180, 140), false});
        taskSpots.push_back({1, "Download Data", "Cafeteria", Vector2D(700, 140), false});
        taskSpots.push_back({2, "Upload Data", "Admin", Vector2D(1050, 220), false});
        taskSpots.push_back({3, "Fix Reactor", "Reactor", Vector2D(480, 540), false});
        taskSpots.push_back({4, "Fuel Engine", "Storage", Vector2D(1350, 500), false});
        taskSpots.push_back({5, "Calibrate", "Security", Vector2D(1350, 220), false});

        cctvPositions.push_back(Vector2D(420, 120));
        cctvPositions.push_back(Vector2D(1270, 170)); // Security Camera
        cctvPositions.push_back(Vector2D(1270, 450)); // Storage Camera

        walls.push_back(RectBounds(80, 80, 1440, 20));
        walls.push_back(RectBounds(80, 680, 1440, 20));
        walls.push_back(RectBounds(80, 80, 20, 620));
        walls.push_back(RectBounds(1520, 80, 20, 620));

    } else { // Level 3
        stationName = "Level 3 - Emergency Station";
        rooms.push_back({"Cafeteria", RectBounds(400, 100, 400, 300), Color(0.12f, 0.16f, 0.22f, 1.0f)});
        rooms.push_back({"Admin", RectBounds(900, 150, 300, 200), Color(0.15f, 0.14f, 0.22f, 1.0f)});
        rooms.push_back({"Electrical", RectBounds(100, 100, 250, 250), Color(0.2f, 0.18f, 0.12f, 1.0f)});
        rooms.push_back({"MedBay", RectBounds(100, 420, 250, 220), Color(0.12f, 0.22f, 0.2f, 1.0f)});
        rooms.push_back({"Reactor", RectBounds(400, 470, 300, 200), Color(0.22f, 0.12f, 0.12f, 1.0f)});
        rooms.push_back({"Navigation", RectBounds(800, 420, 300, 220), Color(0.14f, 0.18f, 0.25f, 1.0f)});
        rooms.push_back({"Security", RectBounds(1250, 150, 250, 250), Color(0.18f, 0.15f, 0.22f, 1.0f)});
        rooms.push_back({"Storage", RectBounds(1250, 430, 250, 240), Color(0.22f, 0.2f, 0.14f, 1.0f)});
        rooms.push_back({"Weapons", RectBounds(400, 720, 400, 200), Color(0.25f, 0.15f, 0.15f, 1.0f)});
        rooms.push_back({"Communications", RectBounds(900, 720, 450, 200), Color(0.15f, 0.22f, 0.25f, 1.0f)});

        emergencyButtonPos = Vector2D(600, 250);

        vents.push_back({0, Vector2D(450, 150), 1});
        vents.push_back({1, Vector2D(950, 180), 4});
        vents.push_back({2, Vector2D(150, 150), 3});
        vents.push_back({3, Vector2D(450, 520), 5});
        vents.push_back({4, Vector2D(1350, 200), 1});
        vents.push_back({5, Vector2D(550, 800), 3});

        taskSpots.push_back({0, "Fix Wiring", "Electrical", Vector2D(180, 140), false});
        taskSpots.push_back({1, "Download Data", "Cafeteria", Vector2D(700, 140), false});
        taskSpots.push_back({2, "Upload Data", "Admin", Vector2D(1050, 220), false});
        taskSpots.push_back({3, "Fix Reactor", "Reactor", Vector2D(480, 540), false});
        taskSpots.push_back({4, "Fuel Engine", "Storage", Vector2D(1350, 500), false});
        taskSpots.push_back({5, "Calibrate", "Security", Vector2D(1350, 220), false});
        taskSpots.push_back({6, "Align Output", "Weapons", Vector2D(600, 800), false});

        cctvPositions.push_back(Vector2D(420, 120));
        cctvPositions.push_back(Vector2D(1270, 170));
        cctvPositions.push_back(Vector2D(420, 740)); // Weapons Camera

        walls.push_back(RectBounds(80, 80, 1440, 20));
        walls.push_back(RectBounds(80, 940, 1440, 20));
        walls.push_back(RectBounds(80, 80, 20, 880));
        walls.push_back(RectBounds(1520, 80, 20, 880));
    }

    for (const auto& room : rooms) {
        waypoints.push_back(Vector2D(room.bounds.x + room.bounds.w / 2.0f, room.bounds.y + room.bounds.h / 2.0f));
    }
}

void Map::update(float deltaTime) {
    cctvAnimTime += deltaTime;
}

void Map::render() const {
    for (const auto& room : rooms) {
        Renderer::drawRect(room.bounds.x, room.bounds.y, room.bounds.w, room.bounds.h, room.floorColor, true);
        Renderer::drawRect(room.bounds.x, room.bounds.y, room.bounds.w, room.bounds.h, Color(0.3f, 0.4f, 0.5f, 1.0f), false);
        Renderer::drawText(room.bounds.x + 15.0f, room.bounds.y + 15.0f, room.name, Color(0.7f, 0.8f, 0.9f, 0.6f), 1.0f);
    }

    for (const auto& wall : walls) {
        Renderer::drawRect(wall.x, wall.y, wall.w, wall.h, Color(0.1f, 0.12f, 0.16f, 1.0f), true);
        Renderer::drawRect(wall.x, wall.y, wall.w, wall.h, Color(0.4f, 0.5f, 0.65f, 1.0f), false);
    }

    Renderer::drawEmergencyButton(emergencyButtonPos.x, emergencyButtonPos.y);

    for (const auto& vent : vents) {
        Renderer::drawVent(vent.position.x, vent.position.y);
    }

    for (const auto& task : taskSpots) {
        Color statusColor = task.isCompleted ? Color(0.2f, 0.9f, 0.3f, 1.0f) : Color(0.9f, 0.8f, 0.2f, 1.0f);
        Renderer::drawConsole(task.position.x, task.position.y, task.taskName, statusColor);
    }

    // Render CCTV Security Cameras with Matrix Scanning Transformation Animations
    for (const auto& cctvPos : cctvPositions) {
        Transform camTrans(cctvPos.x, cctvPos.y);
        Renderer::drawCCTVCamera(camTrans, cctvAnimTime);
    }
}

Vent* Map::getNearbyVent(const Vector2D& playerPos, float maxDist) {
    for (auto& vent : vents) {
        float dx = vent.position.x - playerPos.x;
        float dy = vent.position.y - playerPos.y;
        if (dx * dx + dy * dy <= maxDist * maxDist) {
            return &vent;
        }
    }
    return nullptr;
}

TaskSpot* Map::getNearbyTask(const Vector2D& playerPos, float maxDist) {
    for (auto& task : taskSpots) {
        if (!task.isCompleted) {
            float dx = task.position.x - playerPos.x;
            float dy = task.position.y - playerPos.y;
            if (dx * dx + dy * dy <= maxDist * maxDist) {
                return &task;
            }
        }
    }
    return nullptr;
}

bool Map::isNearEmergencyButton(const Vector2D& playerPos, float maxDist) const {
    float dx = emergencyButtonPos.x - playerPos.x;
    float dy = emergencyButtonPos.y - playerPos.y;
    return (dx * dx + dy * dy <= maxDist * maxDist);
}
