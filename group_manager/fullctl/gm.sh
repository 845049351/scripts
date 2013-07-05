#!/bin/bash
echo "[`date +"%Y-%m-%d %H:%M:%S"`] BEGIN $0 $*" >> gm_history
BIN_PATH=`pwd`;
if [ "$1" == "" ];
then 
  echo Usage: $0 Servername \"your command\"
  echo
  echo EXAMPLE:
  echo $0 all \"your command\"   ------excute at pay web servers running weblogic
  echo $0 halfa \"your command\"   ------excute at servers of halfa running jboss
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

cmd=$2
[ "$cmd" == "" ] && read -p "[Remote] RUN: " cmd
for DEST_SERVER in $SERVERS;do
   echo -e "\033[32;1m  >>>>>>>>>  $DEST_SERVER \033[0m";
   if [ "${cmd/ /}" = "$cmd" ] && [ -f $cmd ];then
      ssh $DEST_SERVER /bin/bash < $cmd
   else
      ssh $DEST_SERVER "$cmd"
   fi
done

echo -e "\033[32;1m------------------------------------------------------------------\033[0m";
echo "=== All done!!! ==="
echo "[`date +"%Y-%m-%d %H:%M:%S"`] DONE  $0 $*" >> gm_history
