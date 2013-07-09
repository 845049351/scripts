#!/bin/bash

baseDir=$(cd "$(dirname "$0")"; pwd)
configDirName=.fscp
configDir=$HOME/$configDirName
binDir=$configDir/bin
lockDir=$configDir/.lock
config=$configDir/list
sshpass=$binDir/sshpass
fscpcmd=$binDir/fscp.sh
rfscpcmd=$configDirName/bin/fscp.sh
sshparam=" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "
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

log() {
	time=`date +'%Y-%m-%d %H:%M:%S'`
	echo "[$time]" $@ >> $configDir/log
}
if [ $# -lt 1 -o $# -lt 2 -a ! -f $config ];then
	help
fi

file=$1
if [ ! -e $file ];then
	log "[ --- ] File Not Exist [$file]"
	exit 0
fi
rpath=$(cd "$(dirname "$file")"; pwd)
[ -d $file ] && rpath=$(cd "$file"; pwd);
# remote relative path to home
rpath=${rpath#$HOME/};
log "[ --- ] Files Will Be Copy To Remote Directory [$rpath]"

shift
ips=$@
[ $# -lt 1 ] && ips=`cat $config`;
ips=($ips)

extract() {
	rm -rf $sshpass;
	mkdir -p $binDir;
	ARCHIVE=`awk '/^__ARCHIVE_BELOW__/ {print NR + 1; exit 0; }' "$0"`
	tail -n+$ARCHIVE "$0" | tar xzvm -C $binDir > /dev/null 2>&1 3>&1
	if [ $? -ne 0 ];then
		log "[ --- ] Extract Binary SSHPASS Fail"
	else
		log "[ --- ] Extract Binary SSHPASS Success"
		chmod +x $sshpass
	fi
}
[ ! -e $sshpass ] && extract
[ ! -e $fscpcmd ] && { cp -rf $0 $binDir; chmod +x $fscpcmd;}

rexec() {
	pIp=$1
	pPw=$2
	pCmd=$3
	log "[REXEC] [$pIp] $pCmd"
	$sshpass -p $pPw ssh $sshparam $pIp "$pCmd"
}
# rsync SCP
rSCP() {
	log "[ RSCP] Not Support"
}
# normal SCP
nSCP() {
	pFile=$1
	pIp=$2
	pPw=$3
	pDir=$4
	param=""

	log "[ NSCP] $pFile => $pIp"

	if [ -d $pFile ];then
		param="-r"
		pDir=$(dirname $pDir)
	fi
	log "[LEXEC] $sshpass -p $pPw scp $sshparam $param $pFile $pIp:$pDir"
	$sshpass -p $pPw scp $sshparam $param $pFile $pIp:$pDir
}
# gzip SCP
zSCP() {
	pFile=$1
	pIp=$2
	pPw=$3
	pDir=$4
	log "[ ZSCP] $pFile => $pIp"

	if [ -d $pFile ];then
		cd $pFile
		tar czf - . | $sshpass -p $pPw ssh $sshparam $pIp tar xzf - -C $pDir
		cd - > /dev/null 2>&1 3>&1
	else
		fileName=$(basename $pFile);
# use gzip
		gzip -c $pFile | $sshpass -p $pPw ssh $sshparam $pIp "gunzip -c - > $pDir/$fileName"
# use tar
		#cd $(dirname $pFile)
		#tar czf - $fileName | $sshpass -p $pPw ssh $sshparam $pIp tar xzf - -C $pDir
		#cd - > /dev/null 2>&1 3>&1
	fi
}
# bzip2 SCP
jSCP() {
	pFile=$1
	pIp=$2
	pPw=$3
	pDir=$4
	log "[ JSCP] $pFile => $pIp"

	if [ -d $pFile ];then
		cd $pFile
		tar cjf - . | $sshpass -p $pPw ssh $sshparam $pIp tar xjf - -C $pDir
		cd - > /dev/null 2>&1 3>&1
	else
		fileName=$(basename $pFile);
# use gzip
		bzip2 -c $pFile | $sshpass -p $pPw ssh $sshparam $pIp "bunzip2 -c - > $pDir/$fileName"
# use tar
		#cd $(dirname $pFile)
		#tar cjf - $fileName | $sshpass -p $pPw ssh $sshparam $pIp tar xjf - -C $pDir
		#cd - > /dev/null 2>&1 3>&1
	fi
}
getIp() {
	echo $1 | cut -d':' -f1
}
getPw() {
	echo $1 | cut -d':' -f2
}
split() {
	gId=$1
	[ "$gId" == "" ] && return 0;
	length=${#ips[@]}
	groupFloor=`echo "$length / $leaf - 1" | bc`;
	groupSize=`echo "scale=2;$length / $leaf - 1" | bc`;
	if [ `echo "$groupSize > $groupFloor"|bc` -eq 1 ];then
		groupSize=$(($groupFloor+1))
	else
		groupSize=$groupFloor
	fi
	idx=`echo "scale=0;$groupSize*$gId+$leaf" | bc`
	#echo gId=$1,length=$length,groupSize=$groupSize,idx=$idx0
	echo ${ips[@]:$idx:$groupSize}
}
lock() {
	pIp=$1
	[ ! -e $lockDir ] && mkdir -p $lockDir
	touch $lockDir/$pIp;
}
unlock() {
	pIp=$1
	[ ! -e $lockDir ] && mkdir -p $lockDir
	rm -rf $lockDir/$pIp;
}
handle() {
	pServer=$1
	pIps=$2
    pIp=`getIp $pServer`
    pPw=`getPw $pServer`
	log "[ >>> ] $pIp"
	# mkdir remote path and fscp config path
	rexec $pIp $pPw "mkdir -p $rpath $configDirName"
	# scp fscp runtime
	nSCP $binDir $pIp $pPw $configDirName
	# scp files
	nSCP $file $pIp $pPw $rpath
#	zSCP $file $pIp $pPw $rpath
#	jSCP $file $pIp $pPw $rpath
	if [ "$pIps" != "" ];then
		# run remote fscp
		if [ -f $file ];then
			fileName=$(basename $file);
			rexec $pIp $pPw "$rfscpcmd $rpath/$fileName $pIps"
		else
			rexec $pIp $pPw "$rfscpcmd $rpath $pIps"
		fi
	fi
	unlock $pIp
}
for i in `seq 0 1 $(($leaf-1))`; do
	if [ "${ips[$i]}" != "" ];then
		lock $pIp
		splitIps=`split $i`
		handle ${ips[$i]} "$splitIps" &
	fi
done;

while [ -d $lockDir ] && [ `ls $lockDir | wc -l` -gt 0 ]  
do
	log "[CHECK] `ls $lockDir | wc -l`"
	sleep 1;
done
log "[ === ] FSCP FINISHED SUCCESS"
exit 0;

#This line must be the last line of the file
# tar -zcvm sshpass >> fscp.sh
__ARCHIVE_BELOW__
