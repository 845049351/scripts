count=0;
time=0;
lx=0;
ly=0;
while [ 1 ];do
	r=`curl -S http://chong.tmall.com/deposit/GetAvailableAwardCount.do`
	x=`echo $r | cut -d':' -f3|cut -d',' -f1`
	y=`echo $r | cut -d':' -f4|cut -d'}' -f1`
	if [[ $x>$count ]]; then
		count=$x;
		time=$y;
	fi
	if [ $x -ne $lx ];then
		a=`echo $y-$ly|bc -l`;
		b=`echo $lx-$x|bc -l`;
		# 越小，获奖率越高
		echo "$a/$b" | bc -l
	fi
	lx=$x;
	ly=$y;
	echo $r>> result
	nsleep 2000;
done
