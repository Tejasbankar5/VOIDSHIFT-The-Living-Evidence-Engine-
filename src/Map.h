#ifndef MAP_H
#define MAP_H

#include <vector>
#include <string>
#include "CollisionSystem.h"
#include "GraphicsAlgorithms.h"

struct Room {
    std::string name;
    RectBounds bounds;
    Color floorColor;

    Room(const std::string& _name = "", const RectBounds& _bounds = RectBounds(), const Color& _color = Color())
        : name(_name), bounds(_bounds), floorColor(_color) {}
};

struct Vent {
    int id;
    Vector2D position;
    int connectedVentId;

    Vent(int _id = 0, const Vector2D& _pos = Vector2D(), int _conn = -1)
        : id(_id), position(_pos), connectedVentId(_conn) {}
};

struct TaskSpot {
    int id;
    std::string taskName;
    std::string roomName;
    Vector2D position;
    bool isCompleted;

    TaskSpot(int _id = 0, const std::string& _tName = "", const std::string& _rName = "", const Vector2D& _pos = Vector2D(), bool _comp = false)
        : id(_id), taskName(_tName), roomName(_rName), position(_pos), isCompleted(_comp) {}
};

class Map {
public:
    int levelNumber;
    std::string stationName;
    std::vector<Room> rooms;
    std::vector<RectBounds> walls;
    std::vector<Vent> vents;
    std::vector<TaskSpot> taskSpots;
    std::vector<Vector2D> waypoints;
    std::vector<Vector2D> cctvPositions;
    Vector2D emergencyButtonPos;

    float cctvAnimTime;

    Map(int level = 1);

    void loadLevel(int level);
    void update(float deltaTime);
    void render() const;

    Vent* getNearbyVent(const Vector2D& playerPos, float maxDist = 45.0f);
    TaskSpot* getNearbyTask(const Vector2D& playerPos, float maxDist = 45.0f);
    bool isNearEmergencyButton(const Vector2D& playerPos, float maxDist = 50.0f) const;
};

#endif // MAP_H
