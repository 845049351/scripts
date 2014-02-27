#!/bin/bash

if [ $# -gt "1" ];then

echo usage:$0 or $0 user!

exit 1

fi

grep log: /etc/passwd

if [ $? = 0 ];then

echo user log exist,start to del it!

userdel -r log

fi

echo user log not exist,start to create it!

groupadd log

sleep 1

useradd -g log log

sleep 1


if [ -n "$1" ];then

user=$1

else

user=`ps -axwww | grep "/bin/sh" | awk -F /home/ '{print $2}' | awk -F / '{print $1}'`

if [ -z $user ];then

user=(admin)

fi

fi

for i in $user

do

release=`cat /etc/redhat-release | awk '{print $10}'`

if [ $release = "6)" ];then

usermod -G $i log
usermod -G ccgroup0 -a log

else

usermod -G $i -a log
usermod -G ccgroup0 -a log

fi

mkdir -p /home/log/$i

ln -s /home/$i/antx.properties /home/log/$i/antx.properties
ln  -s /home/$i/build /home/log/$i/build
ln -s /home/$i/logs /home/log/$i/logs

chown log:log /home/log/$i/
chown log:log /home/log/$i/antx.properties
chown log:log /home/log/$i/build
chown log:log /home/log/$i/logs
chown admin:ccgroup0 /home/$i/logs
chown admin:ccgroup0 /home/$i/build
chown admin:ccgroup0 /home/$i/antx.properties

chmod 755 /home/$i/
chmod -R 750 /home/$i/build
chmod -R 750 /home/$i/logs
chmod -R 750 /home/$i/antx.properties
chmod -R 750 /home/$i/bin

done

echo xixihaha | passwd --stdin log

echo "add users successful!"
