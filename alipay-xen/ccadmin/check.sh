#!/bin/bash
# �趨��������
. /etc/profile
echo"######################"
echo"######`hostname`######"
echo"######################"
echo "���������ļ�����Ŀ¼������"
[ -d /root/ccadmin ] || echo "ccadminĿ¼������"
[ -f /root/ccadmin/cleanlogs.sh ] || echo "cleanlogs.sh�ű�������"
[ -d /home/admin/ccbin ] || echo "ccbinĿ¼������"
[ -d /share/upload ] || echo "/share/uploadĿ¼������"
[ -L /home/admin/sharedata ] || echo "/home/admin/sharedataĿ¼������"
#[ -L /home/log ] || echo "/home/logĿ¼������"

echo "�������������"
[ -d /opt/taobao/install/httpd-2.0.52 ] || echo "httpd-2.0.52������"
[ -d /opt/taobao/install/httpd-2.2.4 ] || echo "httpd-2.2.4������"
[ -d /opt/taobao/install/jboss-4.0.4.GA ] || echo "jboss-4.0.4.GA������"
[ -d /opt/taobao/install/jdk1.6.0_21 ] || echo "jdk1.6.0_21������"
[ -d /opt/taobao/install/jdk1.5.0_08 ] || echo "jdk1.5.0_08������"
echo "���һ�������ʼ���汾"
A=`readlink -s /opt/taobao/install/httpd`
[ "$A" = "httpd-2.2.4" ] && echo "apache ��ʼ����ȷ"
[ "$A" = "httpd-2.2.4" ] || echo "apache ��ʼ������ȷ"
B=`readlink -s /opt/taobao/java`
[ "$B" = "install/jdk1.6.0_21" ] && echo "jdk ��ʼ����ȷ"
[ "$B" = "install/jdk1.6.0_21" ] || echo "jdk ��ʼ������ȷ"
 C=`svn --version | grep "�汾 "` 
[ "$C" = "svn���汾 1.4.3 (r23084)" ] && echo "SVN ��ʼ����ȷ"
[ "$C" = "svn���汾 1.4.3 (r23084)" ] || echo "SVN ��ʼ������ȷ"
#���Ӳ������##
E=`cat /proc/cpuinfo | grep processor | wc -l`
[ $E -eq 4 ] && echo "cpu ��ȷ"
[ $E -eq 4 ] || echo "cpu ����ȷ"
D=`cat /proc/meminfo | grep MemTotal| cut -d : -f 2`
[ "$D" = "4096132 kB" ] && echo "�ڴ��С��ȷ"
[ "$D" = "4096132 kB" ] || echo "�ڴ��С��ȷ"
echo "�ڴ��СΪ��$D "
##��⿪����������##
F=`chkconfig --list | grep "3:����" | cut -f 1 | wc -l`
[ $F -eq 13 ] && echo "�������������ʼ����ȷ"
[ $F -eq 13 ] || echo "�������������ʼ������ȷ"
###�����ļ����###
G=`md5sum /etc/auto.misc | cut -d " " -f 1`
[ "$G" = "0dd382664fe7de2d8ede9a619acb1b9d" ] && echo "auto.misc�ļ���ȷ"
[ "$G" = "0dd382664fe7de2d8ede9a619acb1b9d" ] || echo "auto.misc�ļ�����ȷ"
H=`md5sum /etc/auto.master | cut -d " " -f 1`
[ "$H" = "7e0c252861c96ce3ddbaeac49930860b" ] && echo "auto.master�ļ���ȷ"
[ "$H" = "7e0c252861c96ce3ddbaeac49930860b" ] || echo "auto.master�ļ�����ȷ"
I=`md5sum /etc/audit.rules| cut -d " " -f 1`
[ "$I" = "8fecc694802559ff1cea57057a7a2cdb" ] && echo "audit.rules�ļ���ȷ"
[ "$I" = "8fecc694802559ff1cea57057a7a2cdb" ] || echo "audit.rules�ļ�����ȷ"
J=`md5sum /etc/profile | cut -d " " -f 1`
[ "$J" = "978d2c318a2482a348bb1dffca7dcced" ] && echo "/etc/profile�ļ���ȷ"
[ "$J" = "978d2c318a2482a348bb1dffca7dcced" ] || echo "/etc/profile�ļ�����ȷ"
K=`md5sum /opt/taobao/install/jdk1.5.0_08/jre/lib/security/java.security| cut -d " " -f 1`
[ "$K" = "5f0b24a45af7cc465c3bc11bc86aced7" ] && echo "java.security�ļ���ȷ"
[ "$K" = "5f0b24a45af7cc465c3bc11bc86aced7" ] || echo "java.security�ļ�����ȷ"
[ -f /etc/profile.d ] && echo "WRONG ,/etc/profile.d�ļ�δ����"

#����û�ID	
L=`id admin | cut -d " " -f 1`
[ "$L" = "uid=1801(admin)" ] && echo "admin�û�ID��ȷ"
[ "$L" = "uid=1801(admin)" ] || echo "admin�û�ID����ȷ"
M=`id admin | cut -d "," -f 2`
[ "$M" = "1000(ccgroup0)" ] && echo "admin�û���ID��ȷ"
[ "$M" = "1000(ccgroup0)" ] || echo "admin�û���ID����ȷ"
N=`id log | cut -d " " -f 1`
[ "$N" = "uid=1802(log)" ] && echo "log�û�ID��ȷ"
[ "$N" = "uid=1802(log)" ] || echo "log�û�ID����ȷ"
O=`id log | cut -d "," -f 4 `
[ "$O" = "1000(ccgroup0)" ] && echo "log�û���ID��ȷ"
[ "$O" = "1000(ccgroup0)" ] || echo "log�û���ID����ȷ"
