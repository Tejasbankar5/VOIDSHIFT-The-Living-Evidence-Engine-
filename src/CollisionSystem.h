#ifndef COLLISION_SYSTEM_H
#define COLLISION_SYSTEM_H

#include <vector>
#include "Matrix.h"

struct RectBounds {
    float x, y, w, h; // Top-left origin
    RectBounds(float _x = 0, float _y = 0, float _w = 0, float _h = 0)
        : x(_x), y(_y), w(_w), h(_h) {}

    bool intersects(const RectBounds& other) const {
        return (x < other.x + other.w && x + w > other.x &&
                y < other.y + other.h && y + h > other.y);
    }

    bool contains(float px, float py) const {
        return (px >= x && px <= x + w && py >= y && py <= y + h);
    }
};

struct CircleBounds {
    float cx, cy, radius;
    CircleBounds(float _cx = 0, float _cy = 0, float _r = 0)
        : cx(_cx), cy(_cy), radius(_r) {}

    bool intersectsRect(const RectBounds& rect) const {
        float nearestX = (std::max)(rect.x, (std::min)(cx, rect.x + rect.w));
        float nearestY = (std::max)(rect.y, (std::min)(cy, rect.y + rect.h));
        float dx = cx - nearestX;
        float dy = cy - nearestY;
        return (dx * dx + dy * dy) <= (radius * radius);
    }
};

class CollisionSystem {
public:
    static bool checkCircleRectCollision(float cx, float cy, float radius, const RectBounds& rect);
    static Vector2D resolveCircleRectCollision(float cx, float cy, float radius, const RectBounds& rect);
    static Vector2D resolveMapCollisions(float cx, float cy, float radius, const std::vector<RectBounds>& wallObstacles);
};

#endif // COLLISION_SYSTEM_H
