#!/bin/bash
# db.conf
# host user passwd db expire(days) [table1:table2:table3]
dir=$(cd "$(dirname "$0")"; pwd)
date=`/bin/date +%Y%m%d`
while read line
do
	host=`echo $line | awk '{print $1}'`
	user=`echo $line | awk '{print $2}'`
	passwd=`echo $line | awk '{print $3}'`
	db=`echo $line | awk '{print $4}'`
	expire=`echo $line | awk '{print $5}'`
	ignore_tables=`echo $line | awk '{print $6}'`
	opt=""
	if [ -z $ignore ];then
		tables=`echo ${ignore_tables} | sed "s/:/ /g"`
		for i in $tables
		do
			opt="${opt} --ignore-table=${db}.${i}"
		done
	fi
	dirname="${dir}/../data/${host}/${date}"
	mkdir -p ${dirname}
	find ${dirname} -type d -mtime +${expire} | xargs rm -rf
	echo "/usr/bin/mysqldump $db -h$host -u$user -p$passwd $opt | /bin/gzip > ${dirname}/${db}.sql.gz" > ${dir}/log
	/usr/bin/mysqldump $db -h$host -u$user -p$passwd $opt | /bin/gzip > ${dirname}/${db}.sql.gz
done < ${dir}/db.conf
