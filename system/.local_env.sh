#!/bin/bash
# 将终端改为JDK1.6
export JAVA_HOME="/home/tinghe/program/java"
export PATH=$JAVA_HOME/bin:$PATH

# 设置Oracle
export ORACLE_HOME=/home/tinghe/program/10.2.0.3
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$ORACLE_HOME
export TNS_ADMIN=$ORACLE_HOME/network/admin/tnsnames.ora
export MAVEN_HOME=/home/tinghe/program/apache-maven-2.2.1
export ANT_HOME=/home/tinghe/program/apache-ant-1.7.1
export JMETER_HOME=/home/tinghe/program/apache-jmeter-2.7
export PATH=$PATH:$ORACLE_HOME/lib:$MAVEN_HOME/bin:$JMETER_HOME/bin:$ANT_HOME/bin
export NLS_LANG="SIMPLIFIED CHINESE_CHINA.ZHS16GBK"
export JAVA_OPTS="-XX:+UseParNewGC -Xms256m -Xmx512m"
#export JAVA_OPTS="-XX:+UseParNewGC -Xms128m -Xmx256m -XX:MaxNewSize=64m -XX:NewSize=16m -XX:PermSize=64m -XX:MaxPermSize=96m -XX:CMSInitiatingOccupancyFraction=75 -XX:+CMSIncrementalMode"
#export JBOSS_HOME=/home/tinghe/program/jboss-6.0.0.Final
export CLOUDENGINE_HOME=/home/tinghe/cloudengine
