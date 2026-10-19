@echo off
echo Building 2D Space Deduction Game (C++ OpenGL)...
set MINGW=C:\minGW\bin\g++.exe

%MINGW% -O2 -Wall -std=c++11 ^
src\Matrix.cpp ^
src\Transform.cpp ^
src\GraphicsAlgorithms.cpp ^
src\CoordinateSystem.cpp ^
src\Renderer.cpp ^
src\CollisionSystem.cpp ^
src\Player.cpp ^
src\AIPlayer.cpp ^
src\Map.cpp ^
src\TaskManager.cpp ^
src\SabotageSystem.cpp ^
src\MeetingSystem.cpp ^
src\ScoringSystem.cpp ^
src\UI.cpp ^
src\GraphicsDemo.cpp ^
src\Game.cpp ^
src\main.cpp ^
-o SpaceDeduction2D.exe -lopengl32 -lglu32 -lgdi32 -luser32 -mwindows

if %ERRORLEVEL% EQU 0 (
    echo Build Successful! Run SpaceDeduction2D.exe to play.
) else (
    echo Build Failed! Check errors above.
)
