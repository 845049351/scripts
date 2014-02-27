#!/bin/sh
HOSTNAME=`hostname`
DOMAIN=${HOSTNAME#*.}
[ $DOMAIN = 'alipay.net' -o $DOMAIN = 'stable.alipay.net' ] && sed -i 's/dev/stable/' /root/ccadmin/files/auto.misc
[ $HOSTNAME = 'img.alipay.net' -o $HOSTNAME = 'ecmng.stable.alipay.net' ] && sed -i 's/stable/dev/' /root/ccadmin/files/auto.misc
[ $DOMAIN = 'sit.alipay.net' -o $DOMAIN = 'test.alipay.net' -o $DOMAIN = 'biz.alipay.net' ] && sed -i 's/dev/sit/' /root/ccadmin/files/auto.misc
cp -f /root/ccadmin/files/auto.master /etc/auto.master
cp -f /root/ccadmin/files/auto.misc /etc/auto.misc
[ -d /etc/audit/ ] && cp -f /root/ccadmin/files/audit.rules /etc/audit/audit.rules || cp -f /root/ccadmin/files/audit.rules /etc/audit.rules
rm -rf /home/admin/sharedata
/etc/init.d/portmap restart
/etc/init.d/rpcidmapd restart
/etc/init.d/auditd restart
/etc/init.d/autofs stop &
sleep 2
/usr/bin/killall -9 automount
sleep 1
umount -l /mnt/sharedata &
sleep 2
/etc/init.d/autofs restart
su - admin -c 'ln -s /mnt/sharedata /home/admin/'
