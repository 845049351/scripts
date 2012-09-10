#!/bin/bash

GET_CHAR()
{
SAVEDSTTY=`stty -g`
stty -echo
stty raw
dd if=/dev/tty bs=1 count=1 2> /dev/null
stty -raw
stty echo
stty $SAVEDSTTY
}

if [ $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS ];then
  if [ -d $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS ];then
    cd $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS
  fi
fi

echo "mvn clean eclipse:clean eclipse:eclipse"
mvn clean eclipse:clean eclipse:eclipse
echo "press any key exit..."
GET_CHAR
