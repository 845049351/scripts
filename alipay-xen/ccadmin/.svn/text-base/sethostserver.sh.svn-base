#!/bin/sh
export LANG=en_US
services=$(/sbin/chkconfig --list | grep '3:on' | awk '$1 !~ /^(crond|network|sshd|syslog|sysstat|ntpd|snmpd|portmap|rpcidmapd|autofs|auditd)$/ {print $1}')
for name in $services
do
    /sbin/chkconfig --level 3 $name off
done
/sbin/chkconfig --level 3 crond on
/sbin/chkconfig --level 3 network on
/sbin/chkconfig --level 3 sshd on
/sbin/chkconfig --level 3 syslog on
/sbin/chkconfig --level 3 sysstat on
/sbin/chkconfig --level 3 ntpd on
/sbin/chkconfig --level 3 snmpd on
/sbin/chkconfig --level 3 portmap on
/sbin/chkconfig --level 3 rpcidmapd on
/sbin/chkconfig --level 3 autofs on
/sbin/chkconfig --level 3 auditd on
HOSTNAME=`hostname`
DOMAIN=${HOSTNAME#*.}
[ $DOMAIN = 'alipay.net' -o $DOMAIN = 'stable.alipay.net' ] && sed -i 's/dev/stable/' /root/ccadmin/files/auto.misc
[ $DOMAIN = 'sit.alipay.net' -o $DOMAIN = 'test.alipay.net' -o $DOMAIN = 'biz.alipay.net' ] && sed -i 's/dev/sit/' /root/ccadmin/files/auto.misc
cp -f /root/ccadmin/files/rc.local /etc/rc.local
cp -f /root/ccadmin/files/hosts /etc/hosts
cp -f /root/ccadmin/files/resolv.conf /etc/resolv.conf
cp -f /root/ccadmin/files/snmpd.conf /etc/snmp/snmpd.conf
cp -f /root/ccadmin/files/ntp.conf /etc/ntp.conf
cp -f /root/ccadmin/files/auto.master /etc/auto.master
cp -f /root/ccadmin/files/auto.misc /etc/auto.misc
[ -d /etc/audit/ ] && cp -f /root/ccadmin/files/audit.rules /etc/audit/audit.rules || cp -f /root/ccadmin/files/audit.rules /etc/audit.rules
cp -f /root/ccadmin/files/license_host /var/adm/rational/clearcase/config/license_host
