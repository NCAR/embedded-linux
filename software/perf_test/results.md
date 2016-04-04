Eurotech Titan, AEL Embedded Linux v4i5
    Linux 2.6.35.9-ael1-2-titan #1 PREEMPT Wed Aug 12 13:49:07 MDT 2015 armv5tel unknown
    non-EABI
    arm-linux-g++ (GCC) 3.4.4

    /proc/cpuinfo:
    Processor       : XScale-PXA270 rev 8 (v5l)
    BogoMIPS        : 415.33
    Features        : swp half fastmult edsp iwmmxt 
    CPU implementer : 0x69
    CPU architecture: 5TE
    CPU variant     : 0x0
    CPU part        : 0x411
    CPU revision    : 8

    Hardware        : Eurotech TITAN
    Revision        : 1121
    Serial          : 0000000000000000

    ./float_test_arm 10000000
    n=10000000, sum=16.6953

    real    1m40.687s
    user    0m2.260s
    sys     1m37.610s

    2*10^7 Mflop/100.7 sec = 0.20 Mflops

Eurotech Titan, Debian 8.3 Jessie, EABI
    Linux titan 3.16.0-titan2 #1 PREEMPT Sun Mar 6 12:30:28 MST 2016 armv5tel GNU/Linux
    arm-linux-gnueabi-g++ ( 4.9.2-10) 4.9.2

    /proc/cpuinfo 
    processor       : 0
    model name      : XScale-PXA270 rev 8 (v5l)
    Features        : swp half thumb fastmult edsp iwmmxt 
    CPU implementer : 0x69
    CPU architecture: 5TE
    CPU variant     : 0x0
    CPU part        : 0x411
    CPU revision    : 8

    Hardware        : Eurotech TITAN
    Revision        : 1121
    Serial          : 0000000000000000

    time ./float_test_armel 10000000
    n=10000000, sum=16.6953

    real    0m19.777s
    user    0m19.200s
    sys     0m0.030s

    5 times faster than the non-EABI Titan

    1.01 Mflops

Eurotech Viper, Debian 8.3 Jessie, EABI
    Linux viper 3.16.0-viper2 #1 PREEMPT Fri Mar 4 11:46:15 MST 2016 armv5tel GNU/Linux
    arm-linux-gnueabi-g++ ( 4.9.2-10) 4.9.2

    /proc/cpuinfo 
    processor       : 0
    model name      : XScale-PXA255 rev 6 (v5l)
    Features        : swp half thumb fastmult edsp 
    CPU implementer : 0x69
    CPU architecture: 5TE
    CPU variant     : 0x0
    CPU part        : 0x2d0
    CPU revision    : 6

    Hardware        : Arcom/Eurotech VIPER SBC
    Revision        : 0000
    Serial          : 0000000000000000

    time ./float_test_armel 10000000
    n=10000000, sum=16.6953

    real    0m22.888s
    user    0m20.110s
    sys     0m0.070s

    4.4 times faster than non-EABI Titan

    0.87 Mflops

Dell Precision Desktop, Fedora 23
    Linux porter2 4.4.3-300.fc23.x86_64 #1 SMP Fri Feb 26 18:45:40 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux
    g++ (GCC) 5.3.1 20151207 (Red Hat 5.3.1-2)

    processor  : 0
    vendor_id  : GenuineIntel
    cpu family : 6
    model      : 23
    model name : Intel(R) Xeon(R) CPU           X5472  @ 3.00GHz
    stepping   : 6
    microcode  : 0x60f
    cpu MHz        : 2992.669
    ...

    time $s/float_test_x86_64 10000000
    n=10000000, sum=16.6953

    real    0m0.072s
    user    0m0.069s
    sys 0m0.003s

    1400 times faster than non-EABI Titan
    275 times faster than an EABI Titan

    278 Mflops

