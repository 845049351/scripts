#!/bin/sh

swap_on() {
    sed -i 's/LABEL=SWAP-xvda3/LABEL=SWAP\t/' /etc/fstab
    mkswap -L SWAP /dev/xvda5
    swapon -a
}

grep -q 'LABEL=SWAP-xvda3' /etc/fstab
[[ $? -eq 0 ]] && swap_on
