#!/bin/bash

##������
check_parameter(){
	#����������һ��
	if [ "$#" -ne 1 ];then
		echo "usage: $0 [0-60]"
		exit 1
	fi

	#��������������
	isNumber=$(echo "$1" | grep -E '^[0-9]+$' |wc -c)

	if [ $isNumber -le 0 ];then
		echo "usage: $0 [0-60]"
		exit 1
	fi

	##�������Ƿ��ڷ�Χ��
	if [ "$1" -lt 0 -o "$1" -gt 60 ]; then
		echo "usage: command [0-60]"
		exit 1
	fi
}

process (){
	#��ǰҪ������ص�����
	new_days="$1"

	## ������ǰ��¼�Ŀ�����������ݶ�����
	old_days=$(cat $2 | wc -l)
	declare -a queue

	##�Ѽ������С�ڵ���Ŀ������
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

	##�Ѽ��������ԭ��Ŀ����������������Ŀ������
	if [ $new_days -lt $old_days ];then
	i=0
	while read line
	do
	queue[$i]=$line
	i=$(expr $i + 1)
	done < $2

	queue=(${queue[@]:$(expr $old_days - $new_days)})
	fi

	#echo "���鳤�� ${#queue[@]}"

	#i=0
	#while [ $i -lt ${#queue[@]} ]
	#do
	#echo "�� $i ��Ԫ��=${queue[$i]}"
	#i=$(expr $i + 1)
	#done

	#���buildĿ¼����������Ϊ�������µ�
	if [ ! -e /home/admin/build ];then
	codeStatus="00000|no"
	#���buildĿ¼����
	else 
		svnInfo=$(svn info /home/admin/build/)
		svnInfoLineNum=$(echo "$svnInfo" |wc -l)
		#�ж�svn�����Ƿ�ȡ����10�У����û��10����˵��svn����ʧ�ܣ�����Ϊ���벻�����µ�
		if [ $svnInfoLineNum -ne 10 ];then
			codeStatus="00000|no"
		#���svn������10����ȡ��svn��ַ
		else
		svnAddress=$(echo "$svnInfo" | head -2 | tail -1 |cut -d' ' -f2)
		localVersion=$(echo "$svnInfo" | tail -2 | head -1 | cut -d' ' -f2)
		svnInfo=$(svn info $svnAddress --username=weicai.liu --password=yuhao111 --no-auth-cache --non-interactive)
		svnInfoLineNum=$(echo "$svnInfo" |wc -l)
			if [ $svnInfoLineNum -ne 9 ];then
				codeStatus="00000|no"
			#���svn������10����ȡ��svn��ַ
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
	
	

	##��Զ��һ�������
	queue=(${queue[@]:1})

	##�������ֵ�������β��
	queue[${#queue[@]}]=$codeStatus


	#i=0
	#while [ $i -lt ${#queue[@]} ]
	#do
	#echo "�� $i ��Ԫ��=${queue[$i]}"
	#i=$(expr $i + 1)
	#done


	##��д���
	cat /dev/null > $2
	i=0
	while [ $i -lt ${#queue[@]} ]
	do
	echo ${queue[$i]} >> "$2"
	i=$(expr $i + 1)
	done

	##���㲢����

	i=0
	isLatestCode=0
	##�����������һ���İ汾Ϊ��׼�汾
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

	##������ֵ��Ȼ��0�򱨾�
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
echo '   �������ڼ����������N������û�и���'
echo '   author: ��ɽ'
echo '###################################'
main $1
