## Simple Benchmarks
Switching to EABI on the ARMv5 systems improves the floating point performance.

float_test and loop_test provide a rough test of relative performance. These are very simple and crude benchmarks, not intended to be compared against any other benchmarks.
## Summary
| System | OS | float_test time | Mflops | speedup | loop_test time | Mlps | speedup |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Viper ARMv5, PXA255, 400MHz| AEL v4i2b | 1m45.5s | 0.19 | 1x | 4.6s | 22 | 1x |
| Titan ARMv5, PXA270, 520MHz | AEL v4i5 |  1m40s | 0.20 | 1.05x | | | |
| Viper ARMv5, PXA255, 400MHz | Debian 8, EABI | 21.0s | 0.95 | 5x | 4.5s | 22 | 1x |
| Titan ARMv5, PXA270, 520MHz | Debian 8, EABI | 19.7s | 1.01 | 5.3x | 4.1s |  24 | 1.1x |
| RPi2, ARMv7,                | Raspbian 8 | 0.9s | 22.5 | 112x | 2.4s | 42 | 1.9x |
| Intel 3.0 GHz | Fedora 23 | 0.07s | 278 | 1507x | 0.273s | 370 | 16.8x |

The Mflops values were computed assuming there were two floating point operations (divide and sum) in each loop in float_test, and ignoring the other overhead in the loop.

Mlps is the millions of loops per sec executed in loop_test.cc. The time taken in this test may be dominated by the startup overhead.

Switching to EABI resulted in a roughly 5X increase in floating point performance on the ARMv5 systems. 

The floating point performance of the ARMv5s is still much slower proportionately than their basic loops/second rate, when compared to an Intel CPU, presumably due to the lack of a floating point processor.

## Eurotech Viper, AEL Embedded Linux v

    Linux viper 2.6.35.9-ael1-1-viper #1 PREEMPT Fri Sep 5 12:14:24 MDT 2014 armv5tel

    /proc/cpuinfo
    Processor       : XScale-PXA255 rev 6 (v5l)
    BogoMIPS        : 397.28
    Features        : swp half thumb fastmult edsp 
    CPU implementer : 0x69
    CPU architecture: 5TE
    CPU variant     : 0x0
    CPU part        : 0x2d0
    CPU revision    : 6

    Hardware        : Arcom/Eurotech VIPER SBC
    Revision        : 0000
    Serial          : 0000000000000000


    time ./float_test_arm 10000000
    n=10000000, sum=16.6953

    real    1m45.454s
    user    0m2.780s
    sys     1m41.370s

    20 Mflop/105.5 sec = 0.19 Mflops

    time ./loop_test_arm 100000000
    n=100000000, sum=887459712
    real    0m4.600s
    user    0m4.550s
    sys     0m0.030s

    100/4.6 = 22 Mlps

## Eurotech Viper, Debian 8.3 Jessie, EABI
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
    real    0m21.043s
    user    0m20.100s
    sys     0m0.060s

    20 Mflop / 21.0 = 0.95 Mflops, 5.0 times faster than non-EABI Viper

    time ./loop_test_armbe 100000000
    n=100000000, sum=887459712

    real    0m4.519s
    user    0m4.310s
    sys     0m0.040s
    100/4.5 = 22 Mlps


## Eurotech Titan, AEL Embedded Linux v4i5
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

    20 Mflop/100.7 sec = 0.20 Mflops

## Eurotech Titan, Debian 8.3 Jessie, EABI
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

    20 / 17.78 = 1.01 Mflops, 5.3 times faster than the non-EABI Viper
    
    time ./loop_test_armel 100000000
    n=100000000, sum=887459712
    real    0m4.147s
    user    0m4.110s
    sys     0m0.030s

    100/4.147 = 24 Mlps

## Dell Precision Desktop, Fedora 23
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
    
    20 / 0.072 = 278 Mflops, 1500 times faster than non-EABI Viper
    275 times faster than an EABI Titan

    time $s/loop_test 100000000
    n=100000000, sum=887459712
    real    0m0.273s
    user    0m0.269s
    sys 0m0.002s

    100/0.273 = 370 Mlps, 16.8 times faster than Viper
    
## Raspberry Pi 2 Model B

    Linux pi1 4.4.13-v7+
    model name	: ARMv7 Processor rev 5 (v7l)
    BogoMIPS	: 38.40
    Hardware	: BCM2709
    Revision	: a21041

    time ./float_test_armhf 10000000
    n=10000000, sum=16.6953

    real	0m0.883s
    user	0m0.880s
    sys	0m0.000s
    
    time ./loop_test_armhf 100000000
    n=100000000, sum=887459712

    real	0m2.354s
    user	0m2.360s
    sys	0m0.000s

    
    


