#!/bin/bash
user=admin
rsaDir=rsa_pub
if [ -d $rsaDir ];then
	echo '已存在目录 ('$rsaDir')';
else
	echo '创建目录 ('$rsaDir')';
	mkdir -p $rsaDir;
fi
for machine in `cat machine.sh`
do
	echo '生成rsa验证 :'$machine;
	ssh $user@$machine 'rm -rf ~/.ssh/*;ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ""'
	scp $user@$machine:~/.ssh/id_rsa.pub $rsaDir/$machine.id_rsa.pub 
done
cat $rsaDir/*.id_rsa.pub >> $rsaDir/authorized_keys

for machine in `cat machine.sh`
do
	echo '将信任登录应用到 :'$machine;
	scp  $rsaDir/authorized_keys $user@$machine:~/.ssh/authorized_keys
done
