/* Simple program to exercise floating point operations */
#include <iostream>
#include <cstdlib>
using namespace std;

int main(int argc, char** argv)
{
    unsigned int n=0;

    double sum = 0.0;

    if (argc > 1) n = ::atoi(argv[1]);

    for (unsigned int i = 1; i < n; i++) {
        sum += 1.0 / i;
    }

    cout << "n=" << n << ", sum=" << sum << endl;
    return 0;
}

