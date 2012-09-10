#!/bin/bash
PID=`ps -leaf | grep java | grep server |awk '{print $4}'`;
if [ "$PID" != "" ]; then
  jstat -gcutil -t $PID 2000 1800
else
  echo "not found java process!"
fi