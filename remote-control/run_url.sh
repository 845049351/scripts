#!/bin/bash
. /etc/profile
. ~/.bashrc
cd ~/scripts/remote-control
rm -rf tmp_task.sh
ip=`ifconfig | egrep -o "([0-9]{1,3}\.){3}[0-9]{1,3}" | egrep -v '^255|^127'`
wget -q "http://imbugs.com/task.php?ip=$ip" -O tmp_task.sh
md5=`md5sum tmp_task.sh | awk '{print $1}'`
touch md5.log
exist=`grep $md5 md5.log`
if [ "$exist" == "" ];then
	echo $md5 >> md5.log
	chmod +x tmp_task.sh
	mkdir -p run_dir/ && cd run_dir/
	../tmp_task.sh
else
	exit;
fi
