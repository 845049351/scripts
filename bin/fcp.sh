#!/bin/bash
if [ "$2" == "" ]; then
	echo "usage: $0 file1 [file2 ...] dest"
	echo "强制复制文件到一个目录下面，保持目录结构，目录不存在时自动创建目录."
	exit;
fi
dest=${!#}
mkdir -p $dest;
for i in "$@";do
	if [ "$i" != "$dest" ]; then
		dir=`dirname $i`;
		mkdir -p $dest/$dir;
		echo "cp $i $dest/$i";
		cp -r $i $dest/$dir;
	fi
done
