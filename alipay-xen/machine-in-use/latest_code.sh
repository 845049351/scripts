#!/bin/bash

##检查参数
check_parameter(){
	#参数必须是一个
	if [ "$#" -ne 1 ];then
		echo "usage: $0 [0-60]"
		exit 1
	fi

	#参数必须是数字
	isNumber=$(echo "$1" | grep -E '^[0-9]+$' |wc -c)

	if [ $isNumber -le 0 ];then
		echo "usage: $0 [0-60]"
		exit 1
	fi

	##检查参数是否在范围内
	if [ "$1" -lt 0 -o "$1" -gt 60 ]; then
		echo "usage: command [0-60]"
		exit 1
	fi
}

process (){
	#当前要连续监控的天数
	new_days="$1"

	## 加载以前记录的可用情况到数据队列中
	old_days=$(cat $2 | wc -l)
	declare -a queue

	##已监控天数小于等于目标天数
	if [ $new_days -ge $old_days ];then
	i=0
	while [ $(expr $new_days - $old_days) -gt $i ]
	do
	queue[$i]="00000|yes"
	i=$(expr $i + 1)
	done

	while read line
	do
	if [ $new_days -gt $i ];then
	queue[$i]=$line
	fi
	i=$(expr $i + 1)
	done < $2
	fi

	##已监控天数（原来目标天数）大于现在目标天数
	if [ $new_days -lt $old_days ];then
	i=0
	while read line
	do
	queue[$i]=$line
	i=$(expr $i + 1)
	done < $2

	queue=(${queue[@]:$(expr $old_days - $new_days)})
	fi

	#echo "数组长度 ${#queue[@]}"

	#i=0
	#while [ $i -lt ${#queue[@]} ]
	#do
	#echo "第 $i 个元素=${queue[$i]}"
	#i=$(expr $i + 1)
	#done

	#如果build目录不存在则认为不是最新的
	if [ ! -e /home/admin/build ];then
	codeStatus="00000|no"
	#如果build目录存在
	else 
		svnInfo=$(svn info /home/admin/build/)
		svnInfoLineNum=$(echo "$svnInfo" |wc -l)
		#判断svn命令是否取出了10行，如果没有10行则说明svn命令失败；则认为代码不是最新的
		if [ $svnInfoLineNum -ne 10 ];then
			codeStatus="00000|no"
		#如果svn命令是10行则取出svn地址
		else
		svnAddress=$(echo "$svnInfo" | head -2 | tail -1 |cut -d' ' -f2)
		localVersion=$(echo "$svnInfo" | tail -2 | head -1 | cut -d' ' -f2)
		svnInfo=$(svn info $svnAddress --username=weicai.liu --password=yuhao111 --no-auth-cache --non-interactive)
		svnInfoLineNum=$(echo "$svnInfo" |wc -l)
			if [ $svnInfoLineNum -ne 9 ];then
				codeStatus="00000|no"
			#如果svn命令是10行则取出svn地址
			else
				repositoryVersion=$(echo "$svnInfo" | tail -2 | head -1 | cut -d' ' -f2)
				if [ $repositoryVersion -eq  $localVersion ];then
					codeStatus="$localVersion|yes"
				else
					codeStatus="$localVersion|no"
				fi
			fi
		fi
	fi	
	
	#echo "localVersion=$localVersion;repositoryVersion=$repositoryVersion"
	#echo "codeStatus=$codeStatus"
	
	

	##最远的一天出队列
	queue=(${queue[@]:1})

	##将当天的值加入队列尾部
	queue[${#queue[@]}]=$codeStatus


	#i=0
	#while [ $i -lt ${#queue[@]} ]
	#do
	#echo "第 $i 个元素=${queue[$i]}"
	#i=$(expr $i + 1)
	#done


	##回写结果
	cat /dev/null > $2
	i=0
	while [ $i -lt ${#queue[@]} ]
	do
	echo ${queue[$i]} >> "$2"
	i=$(expr $i + 1)
	done

	##计算并报警

	i=0
	isLatestCode=0
	##队列中最早的一个的版本为基准版本
	baseVersion=$(echo "${queue[0]}"|cut -d'|' -f1)
	while [ $i -lt ${#queue[@]} ]
	do
	version=$(echo "${queue[$i]}"|cut -d'|' -f1)
	status=$(echo "${queue[$i]}"|cut -d'|' -f2)
	if [ $baseVersion -ne $version -o $status = "yes" ];then
		isLatestCode=1
	fi
	i=$(expr $i + 1)
	done

	##如果这个值依然是0则报警
	if [ $isLatestCode -eq 0 ];then
	echo "server code is not latest in the last $new_days days"
	fi
}

main(){
	datafile=$(pwd)/$0.data
	if [ ! -f $datafile ];then
	touch $datafile
	fi
	
	check_parameter $1
	process $1 $datafile
}

echo '###################################'
echo '   程序用于检测代码在最近N天内有没有更新'
echo '   author: 地山'
echo '###################################'
main $1
