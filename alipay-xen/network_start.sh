#!/bin/bash
#³ö´í¾Í»Ø¹ö
set -e

device=$1
vlanid=$2
interface=vlan$vlanid

bridge=$device.$vlanid

modprobe 8021q

vconfig set_name_type VLAN_PLUS_VID_NO_PAD
vconfig add $device $vlanid
ifconfig $interface up

brctl addbr $bridge 
brctl setfd $bridge 0
brctl stp $bridge off
brctl addif $bridge $interface
ifconfig $bridge up

trap - EXIT

exit 0
