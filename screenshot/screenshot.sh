#!/bin/bash
datestr=`date +%Y%m%d%H%M`
export DISPLAY=:0.0
scrot -q 85 /home/tinghe/screenshot/$datestr.jpg
echo "Save Screen $datestr Successfully!"
