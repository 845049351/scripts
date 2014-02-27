
##检查参数
check_parameter(){
	#参数必须是一个
	if [ "$#" -ne 1 ];then
	echo "usage: command [0-60]"
	exit 1
	fi


	#参数必须是数字
	isNumber=$(echo "$1" | grep -E '^[0-9]+$' |wc -c)

	if [ $isNumber -le 0 ];then
	echo "usage: command [0-60]"
	exit 1
	fi

	##检查参数是否在范围内
	if [ "$1" -lt 0 -o "$1" -gt 60 ]; then
	echo "usage: command [0-60]"
	exit 1
	fi

	## 如果参数是0则直接返回，不监控
	if [ "$1" -eq 0 ];then
	exit 0
	fi

}



process (){

	#当前要连续监控的天数
	new_days="$1"
	data_file="$2"

	## 加载以前记录的可用情况到数据队列中
	old_days=$(cat $data_file | wc -l)
	declare -a queue

	##原来无记录，则初始化60天的数据
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
	

	#如果这个文件不存在，则认为服务不可用
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


	##最远的一天出队列

	queue=(${queue[@]:1})

	##将当天的值加入队列尾部

	queue[${#queue[@]}]=$availability


	##回写结果
	cat /dev/null > $2
	i=0
	while [ $i -lt ${#queue[@]} ]
	do
	echo ${queue[$i]} >> "$data_file"
	i=$(expr $i + 1)
	done

	##计算并报警
	
	#获得最近N天的队列值
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
###程序用于检测服务器连续可用性
###author: 地山
###################################
main $1