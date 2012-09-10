#!/bin/bash
for file in `ls -t /opt/bookshelf/books-record`
do
	time=$(($RANDOM%8)) 
	sleep $time
	/home/tinghe/scripts/bookshelf/dodownload.sh $file
done
