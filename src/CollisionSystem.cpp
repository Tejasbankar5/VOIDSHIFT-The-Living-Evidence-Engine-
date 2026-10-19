#include "CollisionSystem.h"
#include <algorithm>
#include <cmath>

bool CollisionSystem::checkCircleRectCollision(float cx, float cy, float radius, const RectBounds& rect) {
    CircleBounds circle(cx, cy, radius);
    return circle.intersectsRect(rect);
}

Vector2D CollisionSystem::resolveCircleRectCollision(float cx, float cy, float radius, const RectBounds& rect) {
    float nearestX = (std::max)(rect.x, (std::min)(cx, rect.x + rect.w));
    float nearestY = (std::max)(rect.y, (std::min)(cy, rect.y + rect.h));
    float dx = cx - nearestX;
    float dy = cy - nearestY;
    float distSq = dx * dx + dy * dy;

    if (distSq < radius * radius && distSq > 0.0001f) {
        float dist = std::sqrt(distSq);
        float overlap = radius - dist;
        float nx = dx / dist;
        float ny = dy / dist;
        return Vector2D(cx + nx * overlap, cy + ny * overlap);
    } else if (distSq == 0.0f) {
        // Circle center is inside box, push out towards nearest edge
        float left = cx - rect.x;
        float right = (rect.x + rect.w) - cx;
        float top = cy - rect.y;
        float bottom = (rect.y + rect.h) - cy;
        float minDist = (std::min)({left, right, top, bottom});

        if (minDist == left) return Vector2D(rect.x - radius, cy);
        if (minDist == right) return Vector2D(rect.x + rect.w + radius, cy);
        if (minDist == top) return Vector2D(cx, rect.y - radius);
        return Vector2D(cx, rect.y + rect.h + radius);
    }
    return Vector2D(cx, cy);
}

Vector2D CollisionSystem::resolveMapCollisions(float cx, float cy, float radius, const std::vector<RectBounds>& wallObstacles) {
    Vector2D pos(cx, cy);
    for (const auto& wall : wallObstacles) {
        if (checkCircleRectCollision(pos.x, pos.y, radius, wall)) {
            pos = resolveCircleRectCollision(pos.x, pos.y, radius, wall);
        }
    }
    return pos;
}
