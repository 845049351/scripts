
##������
check_parameter(){
	#����������һ��
	if [ "$#" -ne 1 ];then
	echo "usage: command [0-60]"
	exit 1
	fi


	#��������������
	isNumber=$(echo "$1" | grep -E '^[0-9]+$' |wc -c)

	if [ $isNumber -le 0 ];then
	echo "usage: command [0-60]"
	exit 1
	fi

	##�������Ƿ��ڷ�Χ��
	if [ "$1" -lt 0 -o "$1" -gt 60 ]; then
	echo "usage: command [0-60]"
	exit 1
	fi

	## ���������0��ֱ�ӷ��أ������
	if [ "$1" -eq 0 ];then
	exit 0
	fi

}



process (){

	#��ǰҪ������ص�����
	new_days="$1"
	data_file="$2"

	## ������ǰ��¼�Ŀ�����������ݶ�����
	old_days=$(cat $data_file | wc -l)
	declare -a queue

	##ԭ���޼�¼�����ʼ��60�������
	if [ $old_days -ne 60 ];then
		i=0
		while [ 60 -gt $i ]
		do
			queue[$i]="enable"
			i=$(expr $i + 1)
		done
	else
		while read line
		do
			queue[$i]=$line
			i=$(expr $i + 1)
		done < $data_file
	fi
	

	#�������ļ������ڣ�����Ϊ���񲻿���
	if [ ! -f /home/admin/ccbin/checkservice.sh ];then
		availability="disable"
	else
		check_result=$(sh /home/admin/ccbin/checkservice.sh | grep "OK" |wc -w)
		if [ $check_result -ne 0 ];then
		availability="enable"
		else
		availability="disable"
		fi
	fi


	##��Զ��һ�������

	queue=(${queue[@]:1})

	##�������ֵ�������β��

	queue[${#queue[@]}]=$availability


	##��д���
	cat /dev/null > $2
	i=0
	while [ $i -lt ${#queue[@]} ]
	do
	echo ${queue[$i]} >> "$data_file"
	i=$(expr $i + 1)
	done

	##���㲢����
	
	#������N��Ķ���ֵ
	queue=(${queue[@]: $(expr ${#queue[@]} - $new_days)})
		
	i=0
	service_ok=0
	while [ $i -lt ${#queue[@]} ]
	do
	if [ "${queue[$i]}" = "enable" ];then
	service_ok=$(expr $service_ok + 1)
	fi
	i=$(expr $i + 1)
	done

	if [ $service_ok -le 0 ];then
	echo "disable"
	else
	echo "enable"
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

###################################
###�������ڼ�����������������
###author: ��ɽ
###################################
main $1