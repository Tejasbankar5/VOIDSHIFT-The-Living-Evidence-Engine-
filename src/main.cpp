#include <windows.h>
#include <GL/gl.h>
#include <GL/glu.h>
#include <chrono>
#include "Game.h"

static Game* g_pGame = nullptr;

LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam) {
    switch (message) {
        case WM_SIZE: {
            int width = LOWORD(lParam);
            int height = HIWORD(lParam);
            if (height == 0) height = 1;
            if (g_pGame != nullptr) {
                g_pGame->screenWidth = (float)width;
                g_pGame->screenHeight = (float)height;
                g_pGame->coordSys.updateScreenSize(width, height);
                Renderer::initGL(width, height);
            }
            return 0;
        }
        case WM_KEYDOWN: {
            if (g_pGame != nullptr) {
                g_pGame->handleKeyDown((unsigned char)wParam);
            }
            return 0;
        }
        case WM_KEYUP: {
            if (g_pGame != nullptr) {
                g_pGame->handleKeyUp((unsigned char)wParam);
            }
            return 0;
        }
        case WM_MOUSEMOVE: {
            if (g_pGame != nullptr) {
                float x = (float)LOWORD(lParam);
                float y = (float)HIWORD(lParam);
                g_pGame->handleMouseMove(x, y);
            }
            return 0;
        }
        case WM_LBUTTONDOWN: {
            if (g_pGame != nullptr) {
                float x = (float)LOWORD(lParam);
                float y = (float)HIWORD(lParam);
                g_pGame->handleMouseClick(x, y, true);
            }
            return 0;
        }
        case WM_LBUTTONUP: {
            if (g_pGame != nullptr) {
                float x = (float)LOWORD(lParam);
                float y = (float)HIWORD(lParam);
                g_pGame->handleMouseClick(x, y, false);
            }
            return 0;
        }
        case WM_DESTROY: {
            PostQuitMessage(0);
            return 0;
        }
        default:
            return DefWindowProc(hWnd, message, wParam, lParam);
    }
}

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
    WNDCLASSEX wc;
    ZeroMemory(&wc, sizeof(WNDCLASSEX));
    wc.cbSize = sizeof(WNDCLASSEX);
    wc.style = CS_HREDRAW | CS_VREDRAW | CS_OWNDC;
    wc.lpfnWndProc = WndProc;
    wc.hInstance = hInstance;
    wc.hCursor = LoadCursor(NULL, IDC_ARROW);
    wc.hbrBackground = (HBRUSH)GetStockObject(BLACK_BRUSH);
    wc.lpszClassName = "SpaceDeduction2DWndClass";

    if (!RegisterClassEx(&wc)) {
        MessageBox(NULL, "Failed to register window class!", "Error", MB_ICONERROR);
        return 1;
    }

    int windowWidth = 1280;
    int windowHeight = 720;

    RECT wr = {0, 0, windowWidth, windowHeight};
    AdjustWindowRect(&wr, WS_OVERLAPPEDWINDOW, FALSE);

    HWND hWnd = CreateWindowEx(
        0, "SpaceDeduction2DWndClass", "Space Deduction 2D — Computer Graphics Prototype",
        WS_OVERLAPPEDWINDOW | WS_VISIBLE,
        CW_USEDEFAULT, CW_USEDEFAULT,
        wr.right - wr.left, wr.bottom - wr.top,
        NULL, NULL, hInstance, NULL
    );

    if (!hWnd) {
        MessageBox(NULL, "Failed to create window!", "Error", MB_ICONERROR);
        return 1;
    }

    HDC hDC = GetDC(hWnd);

    PIXELFORMATDESCRIPTOR pfd;
    ZeroMemory(&pfd, sizeof(PIXELFORMATDESCRIPTOR));
    pfd.nSize = sizeof(PIXELFORMATDESCRIPTOR);
    pfd.nVersion = 1;
    pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER;
    pfd.iPixelType = PFD_TYPE_RGBA;
    pfd.cColorBits = 32;
    pfd.cDepthBits = 24;
    pfd.cStencilBits = 8;

    int pixelFormat = ChoosePixelFormat(hDC, &pfd);
    SetPixelFormat(hDC, pixelFormat, &pfd);

    HGLRC hRC = wglCreateContext(hDC);
    wglMakeCurrent(hDC, hRC);

    Renderer::initGL(windowWidth, windowHeight);

    Game game(windowWidth, windowHeight);
    g_pGame = &game;

    ShowWindow(hWnd, nCmdShow);
    UpdateWindow(hWnd);

    auto lastTime = std::chrono::high_resolution_clock::now();

    MSG msg;
    bool running = true;

    while (running) {
        while (PeekMessage(&msg, NULL, 0, 0, PM_REMOVE)) {
            if (msg.message == WM_QUIT) {
                running = false;
                break;
            }
            TranslateMessage(&msg);
            DispatchMessage(&msg);
        }

        if (!running) break;

        auto currentTime = std::chrono::high_resolution_clock::now();
        float deltaTime = std::chrono::duration<float>(currentTime - lastTime).count();
        lastTime = currentTime;

        if (deltaTime > 0.1f) deltaTime = 0.1f; // Cap max delta frame time

        game.update(deltaTime);
        game.render();

        SwapBuffers(hDC);
        Sleep(1); // Yield CPU slightly
    }

    wglMakeCurrent(NULL, NULL);
    wglDeleteContext(hRC);
    ReleaseDC(hWnd, hDC);
    DestroyWindow(hWnd);

    return 0;
}
