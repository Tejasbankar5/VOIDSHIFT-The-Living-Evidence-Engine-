@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

set "GODOT_EXE=C:\Users\tejas\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe"
if not exist "!GODOT_EXE!" (
    set "GODOT_EXE=C:\Users\tejas\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe"
)

if exist "%~dp0godot_game\project.godot" (
    "!GODOT_EXE!" --path "%~dp0godot_game"
) else if exist "%~dp0project.godot" (
    "!GODOT_EXE!" --path "%~dp0."
) else (
    echo Cannot find project.godot!
    pause
)
