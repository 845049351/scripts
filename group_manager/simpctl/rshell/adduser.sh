#!/bin/sh
user='user1
user2
user3';

for i in `echo $user`
do
echo $i
adduser $i
echo "passwd" | passwd --stdin "$i"
echo "USER $i:passwd"
done
