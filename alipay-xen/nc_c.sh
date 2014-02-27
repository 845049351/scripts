#!/bin/bash
#v1.1
ifconfig  | grep inet | grep -q 10.253 || exit

oip=`ifconfig  | grep inet | grep 10.253 | awk '{print $2}' | sed "s/addr://"`
ho=hostinfo
nhi=(`grep $oip[^0-9] $ho`)
b0=/etc/sysconfig/network-scripts/ifcfg-bond0
e0=/etc/sysconfig/network-scripts/ifcfg-eth0
e1=/etc/sysconfig/network-scripts/ifcfg-eth1
ntk=/etc/sysconfig/network
pwdxn=/etc/xen/auto

i_xc () {
[ -d /etc/xen ] && cp  /etc/xen/scripts/network-bridge /root/network-bridge.old  
[ -d /etc/xen ] && cp  /etc/xen/xend-config.sxp /root/xend-config.sxp.old
[ -d /etc/xen ] && cp network-bridge /etc/xen/scripts/network-bridge
[ -d /etc/xen ] && cp xend-config.sxp /etc/xen/xend-config.sxp
}

i_trunk () {
grep -q "^VLAN=yes" $ntk || echo VLAN=yes >> $ntk
}
i_cgw () {
sed -i '/GATEWAY/d' /etc/sysconfig/network
}
i_modp () {
grep -q 'mode=1' /etc/modprobe.conf || cat << EOF >> /etc/modprobe.conf
alias bond0 bonding
options bond0 miimon=100 mode=1 primary=eth0
EOF
}

i_bond0_s () {
cat << EOF > $b0
DEVICE=bond0
BOOTPROTO=none
ONBOOT=yes
USERCTL=no
EOF
}

i_bond0_vid () {
nk=`echo $1 | awk -F. '{print $1"."$2"."$3".0"}'`
bt=`echo $1 | awk -F. '$3=$3+3 {print $1"."$2"."$3".255"}'`
cat << EOF > $b0.$2
DEVICE=bond0.$2
BOOTPROTO=none
IPADDR=$1
NETMASK=$5
GATEWAY=$4
ONBOOT=yes
USERCTL=no
EOF
}

i_bg () {

cd /root ;sh network_start.sh bond0 $1
grep network_start  /etc/rc.local || echo 'cd /root;sh network_start.sh bond0 ' $1 >> /etc/rc.local

#echo $3 | grep -q none || cat << EOF > $b0.$3
#DEVICE=bond0.$3
#BOOTPROTO=none
#ONBOOT=yes
#USERCTL=no
#EOF
}

i_bond0_vm () {
nk=`echo $1 | awk -F. '{print $1"."$2"."$3".0"}'`
bt=`echo $1 | awk -F. '$3=$3+3 {print $1"."$2"."$3".255"}'`
cat << EOF > $b0
DEVICE=bond0
BOOTPROTO=none
IPADDR=$1
NETMASK=$5
GATEWAY=$4
ONBOOT=yes
USERCTL=no
EOF
}

i_eth01 () {
cat << EOF  > $e0
DEVICE=eth0
BOOTPROTO=none
ONBOOT=yes
USERCTL=no
MASTER=bond0
SLAVE=yes
EOF
cat << EOF  > $e1
DEVICE=eth1
BOOTPROTO=none
ONBOOT=yes
USERCTL=no
MASTER=bond0
SLAVE=yes
EOF
}

i_vm_f () {
	cd $pwdxn &&  for xf in `ls`;do
		grep -q bond0 $xf && continue
		bf=`cat $xf  | awk '/vif/{print $4}' | sed "s/eth0/bond0.$1/"`
		sed -i  "s/vif/#vif/" $xf;sed -i "/vif/a vif = [ $bf ]" $xf;
	done 
} 

#main 
case ${nhi[6]} in
	dom0)
		echo dom0 action
		for i in ${nhi[*]};do
			echo $i action
		done
		i_modp
                i_xc
                i_bg ${nhi[3]}
		i_trunk
		i_bond0_s
		#i_bond0_vid IP VID1 VID2 GW NETMASK
		i_bond0_vid ${nhi[1]} ${nhi[2]}  ${nhi[3]}  ${nhi[7]}  ${nhi[8]}
		i_eth01
		i_vm_f ${nhi[3]}
		i_cgw
		echo action done
	;;
	vm)
		echo vm action
		for i in ${nhi[*]};do
			echo $i 
		done
		i_modp
		i_bond0_vm ${nhi[1]} ${nhi[2]}  ${nhi[3]}  ${nhi[7]}  ${nhi[8]}
		i_eth01
		i_cgw
		echo action done
	;;
	norm)
		echo nor action
		for i in ${nhi[*]};do
			echo $i 
		done
		i_modp
		i_bond0_s
		i_bond0_vid ${nhi[1]} ${nhi[2]}  ${nhi[3]}  ${nhi[7]}  ${nhi[8]}
		i_eth01
		i_trunk
		i_cgw
		echo action done
	;;
	*)
		echo not in merge list
	;;
esac
