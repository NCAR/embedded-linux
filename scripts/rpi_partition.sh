#!/bin/sh

if [ $# -lt 2 ]; then
    echo "Usage ${0##*/} device p2size"
    echo "p2size is something like 4G"
    exit 1
fi
fdev=$1
sizep2=$2

startp2=$(fdisk -l $fdev  | grep ${fdev}p2 | awk '{print $2}')

fdisk $fdev << EOD
d
3
d
2
n
p
2
$startp2
+$sizep2
w
EOD

endp2=$(fdisk -l $fdev | grep ${fdev}p2 | awk '{print $3}')
endp2=$(( $endp2 + 1 ))

# echo $endp2

fdisk $fdev << EOD
n
p
3
$endp2

w
EOD

resize2fs ${fdev}p2
mkfs.ext4 ${fdev}p3



