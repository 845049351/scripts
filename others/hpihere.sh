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

echo "mvn hpi:run"
export JAVA_HOME="/home/tinghe/program/jdk1.6.0_17"
export PATH=$JAVA_HOME/bin:$PATH
export MAVEN_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,address=8000,suspend=n"
mvn hpi:run
echo "press any key exit..."
GET_CHAR
