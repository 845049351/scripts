#!/bin/bash
echo "[`date +"%Y-%m-%d %H:%M:%S"`] BEGIN $0 $*" >> gm_history
BIN_PATH=`pwd`;
if [ "$1" == "" ];
then 
  echo Usage: $0 Servername file target
  echo
  echo EXAMPLE:
  echo $0 all file target   ------copy file to remote target
  echo
  exit 1

elif [ "$1" = "all" ];
then
  SERVERS=`$BIN_PATH/getvalue all.group`
elif [ "$1" = "halfa" ];
then
  SERVERS=`$BIN_PATH/getvalue halfa.group`
elif [ "$1" = "halfb" ];
then
  SERVERS=`$BIN_PATH/getvalue halfb.group`
else
  SERVERS=`$BIN_PATH/getvalue $1`
fi

[ $? -eq 1 ] && exit 0;

file=$2
target=$3
[ -z $file ] && read -p "[Local] File(Dir): " file
[ -z $target ] && read -p "[Remote] Target: " target

if [ ! -e $file ]; then
	echo "File Not Exist !"
	exit 0;
fi

param=""
[ -d $file ] && param="-r"

for DEST_SERVER in $SERVERS;do
   echo -e "\033[32;1m  >>>>>>>>>  $DEST_SERVER \033[0m";
   scp $param $file $DEST_SERVER:$target
done

echo -e "\033[32;1m------------------------------------------------------------------\033[0m";
echo "=== All done!!! ==="
echo "[`date +"%Y-%m-%d %H:%M:%S"`] DONE  $0 $*" >> gm_history
