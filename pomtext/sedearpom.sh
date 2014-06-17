#!/bin/bash
#if [ "$1" == "" ];then
#	echo "缺少参数"
#	exit 1
#fi

FILE="/home/tinghe/imbugs-source/sit/cif/cif/test/test/pom.xml"
cat earpomh	> temp
cat $FILE | grep '<groupId>' | sed -n '2p' >> temp
cat $FILE | grep '<artifactId>' | sed -n '2p' >> temp
cat $FILE | grep '<version>' | sed -n '2p' >> temp
cat earpome >> temp

sed  '/<plugins>/ {
r temp
}' /home/tinghe/imbugs-source/sit/prodtrans/assembly/prodtrans-ear/pom.xml

