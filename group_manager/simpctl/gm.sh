#!/bin/bash
cmd=$1
[ "$cmd" == "" ] && read -p "[Remote] RUN(Script): " cmd

for i in `cat list`;do
   if [ "${cmd/ /}" = "$cmd" ] && [ -f $cmd ];then
      ssh $i /bin/bash < $cmd
   else
      ssh $i "$cmd"
   fi
done
