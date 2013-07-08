#!/bin/bash

baseDir=$(cd "$(dirname "$0")"; pwd)
configDir=$HOME/.fscp
config=$configDir/list
sshpass=$configDir/sshpass
leaf=3;

help() {
	cat << EOF
Usage: $0 file(directory) [user1@ip1:passwd1] [user2@ip2:passwd2] [...]
	you can alse to edit config file $config, example:
	user1@ip1:passwd1
	user2@ip2:passwd2
EOF
	exit;
}

if [ $# -lt 1 -o $# -lt 2 -a ! -f $config ];then
	help
fi

file=$1
rpath=$(cd "$(dirname "$file")"; pwd)
[ -d $file ] && rpath=$(cd "$file"; pwd);
# remote relative path to home
rpath=${rpath#$HOME/};
echo "Files Will Be Copy To Remote Directory [$rpath]"

shift
ips=$@
[ $# -lt 1 ] && ips=`cat $config`;
ips=($ips)

extract() {
	rm -rf $sshpass;
	mkdir -p $configDir;
	ARCHIVE=`awk '/^__ARCHIVE_BELOW__/ {print NR + 1; exit 0; }' "$0"`
	tail -n+$ARCHIVE "$0" | tar xzvm -C $configDir > /dev/null 2>&1 3>&1
	if [ $? -ne 0 ];then
		echo "Extract Binary SSHPASS Fail"
	else
		echo "Extract Binary SSHPASS Success"
		chmod +x $sshpass
	fi
}
if [ ! -e $sshpass ];then
	extract
fi

zSCP() {
	RHOME=`sshpass -p xixihaha ssh log@msgbroker-22.bjl.alipay.net pwd`
#tar czf - $file | ssh joebloggs@otherserver.com tar xzf - -C ~/
}
jSCP() {
	RHOME=`sshpass -p xixihaha ssh log@msgbroker-22.bjl.alipay.net pwd`
#tar cjf - $file | ssh joebloggs@otherserver.com tar xjf - -C ~/
}
nSCP() {
	pFile=$1
	pServer=$2
	pDir=$3
    pIp=`getIp $pServer`
    pPw=`getPw $pServer`
	param=""
	[ -d $pFile ] && param="-r"
	echo $sshpass -p $pPw scp $param $pFile $pIp:$pDir
	$sshpass -p $pPw scp $param $pFile $pIp:$pDir
}
getIp() {
	echo $1 | cut -d':' -f1
}
getPw() {
	echo $1 | cut -d':' -f2
}
rexec() {
	pServer=$1
	pCmd=$2
    pIp=`getIp $pServer`
    pPw=`getPw $pServer`
	echo $sshpass -p $pPw ssh $pIp $pCmd
	$sshpass -p $pPw ssh $pIp $pCmd
}

for i in `seq 0 1 $(($leaf-1))`; do
	if [ "${ips[$i]}" != "" ];then

		rexec ${ips[$i]} "mkdir -p $rpath"
		nSCP $configDir ${ips[$i]} ""
		nSCP $file ${ips[$i]} $rpath
	fi
done;

exit 0;
#This line must be the last line of the file
# tar -zcvm sshpass >> fscp.sh
__ARCHIVE_BELOW__
