#!/bin/bash
. /etc/profile
# purpose clean logs
#version 1.0
#date 2012-03-05
#modify by ½­ÔÆ
APPDATE=7
SYSDATE=14
if [ -d /home/admin/logs ];then
echo "start clean logs" >>/home/admin/logs/cleanlogs.log
find  /home/admin/logs -mtime  +$APPDATE -type f -size +1c|xargs rm -fv >>/home/admin/logs/cleanlogs.log
date >>/home/admin/logs/cleanlogs.log
fi
if [ -d /var/log ];then
echo "finish clean" >>/home/admin/logs/cleanlogs.log
echo "start clean logs" >>/var/log/cleanlogs.log
find  /var/log -mtime  +$SYSDATE -type f -size +1c|xargs rm -fv >>/var/log/cleanlogs.log
date >>/var/log/cleanlogs.log
echo "finish clean" >>/var/log/cleanlogs.log
fi
