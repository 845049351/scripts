#!/bin/bash
WALLTIME=/proc/sys/xen/independent_wallclock
NTPD=/etc/init.d/ntpd
DATE=`which date`

if [ "$#" == "0" ] ;then
echo Usage:./setime.sh TIME
echo Time Format:[MMDDhhmm[[CC]YY][.ss]]
exit
fi

setwall (){
    $NTPD stop
    echo 1 > $WALLTIME
    $DATE -s $1
}

(fdisk -l | grep xvd 2>&1> /dev/null) && setwall $1
