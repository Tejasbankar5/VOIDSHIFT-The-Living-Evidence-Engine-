#include <iostream>
#include <cstdlib>
using namespace std;

void BresenhamLine(int x1, int y1, int x2, int y2)
{
    int dx = x2 - x1;
    int dy = y2 - y1;

    int p = 2 * dy - dx;

    int x = x1;
    int y = y1;

    cout << "(" << x << ", " << y << ")" << endl;

    while (x < x2)
    {
        x++;

        if (p < 0)
        {
            p = p + 2 * dy;
        }
        else
        {
            y++;
            p = p + 2 * dy - 2 * dx;
        }

        cout << "(" << x << ", " << y << ")" << endl;
    }
}

int main()
{
    int x1, y1, x2, y2;

    cout << "Enter x1 y1: ";
    cin >> x1 >> y1;

    cout << "Enter x2 y2: ";
    cin >> x2 >> y2;

    BresenhamLine(x1, y1, x2, y2);

    return 0;
}