#!/bin/bash
week=`date +%w`;
if [ $week -eq 0 ] || [ $week -eq 6 ];then 
	echo "weekend";
else 
	echo "workday";
fi
