#include <iostream>
using namespace std;

void plotPoints(int xc, int yc, int x, int y)
{
    cout << "(" << xc + x << ", " << yc + y << ")" << endl;
    cout << "(" << xc - x << ", " << yc + y << ")" << endl;
    cout << "(" << xc + x << ", " << yc - y << ")" << endl;
    cout << "(" << xc - x << ", " << yc - y << ")" << endl;

    cout << "(" << xc + y << ", " << yc + x << ")" << endl;
    cout << "(" << xc - y << ", " << yc + x << ")" << endl;
    cout << "(" << xc + y << ", " << yc - x << ")" << endl;
    cout << "(" << xc - y << ", " << yc - x << ")" << endl;
}

void MidpointCircle(int xc, int yc, int r)
{
    int x = 0;
    int y = r;

    int p = 1 - r;

    while (x <= y)
    {
        plotPoints(xc, yc, x, y);

        if (p < 0)
        {
            x++;
            p = p + 2 * x + 1;
        }
        else
        {
            x++;
            y--;
            p = p + 2 * x - 2 * y + 1;
        }
    }
}

int main()
{
    int xc, yc, r;

    cout << "Enter center (xc, yc): ";
    cin >> xc >> yc;

    cout << "Enter radius: ";
    cin >> r;

    MidpointCircle(xc, yc, r);

    return 0;
}