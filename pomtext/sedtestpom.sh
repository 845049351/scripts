#!/bin/bash
if [ "$1" == "" ];then
	echo "缺少参数"
	exit 1
fi
sed -i '/<plugins>/ {
r testpom
}' $1
