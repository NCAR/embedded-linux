/* Simple program to exercise integer operations */
#include <iostream>
#include <cstdlib>
using namespace std;

int main(int argc, char** argv)
{
    unsigned int n=0;

    unsigned int sum = 0;

    if (argc > 1) n = ::atoi(argv[1]);

    for (unsigned int i = 0; i < n; i++) {
        sum += i;
    }

    cout << "n=" << n << ", sum=" << sum << endl;
    return 0;
}

