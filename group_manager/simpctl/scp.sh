#!/bin/bash
file=$1
target=$2
[ -z $file ] && read -p "[Local] File(Dir): " file
[ -z $target ] && read -p "[Remote] Target: " target

if [ ! -e $file ]; then
	echo "File Not Exist !"
	exit 0;
fi

param=""
[ -d $file ] && param="-r"
for i in `cat list`;do
   echo "=== $i ==="
   scp $param $file $i:$target
done
