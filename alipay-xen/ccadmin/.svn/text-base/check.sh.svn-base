#!/bin/bash
# 设定环境变量
. /etc/profile
echo"######################"
echo"######`hostname`######"
echo"######################"
echo "以下配置文件或是目录不存在"
[ -d /root/ccadmin ] || echo "ccadmin目录不存在"
[ -f /root/ccadmin/cleanlogs.sh ] || echo "cleanlogs.sh脚本不存在"
[ -d /home/admin/ccbin ] || echo "ccbin目录不存在"
[ -d /share/upload ] || echo "/share/upload目录不存在"
[ -L /home/admin/sharedata ] || echo "/home/admin/sharedata目录不存在"
#[ -L /home/log ] || echo "/home/log目录不存在"

echo "以下软件不存在"
[ -d /opt/taobao/install/httpd-2.0.52 ] || echo "httpd-2.0.52不存在"
[ -d /opt/taobao/install/httpd-2.2.4 ] || echo "httpd-2.2.4不存在"
[ -d /opt/taobao/install/jboss-4.0.4.GA ] || echo "jboss-4.0.4.GA不存在"
[ -d /opt/taobao/install/jdk1.6.0_21 ] || echo "jdk1.6.0_21不存在"
[ -d /opt/taobao/install/jdk1.5.0_08 ] || echo "jdk1.5.0_08不存在"
echo "检测一下软件初始化版本"
A=`readlink -s /opt/taobao/install/httpd`
[ "$A" = "httpd-2.2.4" ] && echo "apache 初始化正确"
[ "$A" = "httpd-2.2.4" ] || echo "apache 初始化不正确"
B=`readlink -s /opt/taobao/java`
[ "$B" = "install/jdk1.6.0_21" ] && echo "jdk 初始化正确"
[ "$B" = "install/jdk1.6.0_21" ] || echo "jdk 初始不化正确"
 C=`svn --version | grep "版本 "` 
[ "$C" = "svn，版本 1.4.3 (r23084)" ] && echo "SVN 初始化正确"
[ "$C" = "svn，版本 1.4.3 (r23084)" ] || echo "SVN 初始化不正确"
#检测硬件配置##
E=`cat /proc/cpuinfo | grep processor | wc -l`
[ $E -eq 4 ] && echo "cpu 正确"
[ $E -eq 4 ] || echo "cpu 不正确"
D=`cat /proc/meminfo | grep MemTotal| cut -d : -f 2`
[ "$D" = "4096132 kB" ] && echo "内存大小正确"
[ "$D" = "4096132 kB" ] || echo "内存大小正确"
echo "内存大小为：$D "
##检测开机启动进程##
F=`chkconfig --list | grep "3:启用" | cut -f 1 | wc -l`
[ $F -eq 13 ] && echo "开机启动程序初始化正确"
[ $F -eq 13 ] || echo "开机启动程序初始化不正确"
###配置文件检测###
G=`md5sum /etc/auto.misc | cut -d " " -f 1`
[ "$G" = "0dd382664fe7de2d8ede9a619acb1b9d" ] && echo "auto.misc文件正确"
[ "$G" = "0dd382664fe7de2d8ede9a619acb1b9d" ] || echo "auto.misc文件不正确"
H=`md5sum /etc/auto.master | cut -d " " -f 1`
[ "$H" = "7e0c252861c96ce3ddbaeac49930860b" ] && echo "auto.master文件正确"
[ "$H" = "7e0c252861c96ce3ddbaeac49930860b" ] || echo "auto.master文件不正确"
I=`md5sum /etc/audit.rules| cut -d " " -f 1`
[ "$I" = "8fecc694802559ff1cea57057a7a2cdb" ] && echo "audit.rules文件正确"
[ "$I" = "8fecc694802559ff1cea57057a7a2cdb" ] || echo "audit.rules文件不正确"
J=`md5sum /etc/profile | cut -d " " -f 1`
[ "$J" = "978d2c318a2482a348bb1dffca7dcced" ] && echo "/etc/profile文件正确"
[ "$J" = "978d2c318a2482a348bb1dffca7dcced" ] || echo "/etc/profile文件不正确"
K=`md5sum /opt/taobao/install/jdk1.5.0_08/jre/lib/security/java.security| cut -d " " -f 1`
[ "$K" = "5f0b24a45af7cc465c3bc11bc86aced7" ] && echo "java.security文件正确"
[ "$K" = "5f0b24a45af7cc465c3bc11bc86aced7" ] || echo "java.security文件不正确"
[ -f /etc/profile.d ] && echo "WRONG ,/etc/profile.d文件未处理"

#检测用户ID	
L=`id admin | cut -d " " -f 1`
[ "$L" = "uid=1801(admin)" ] && echo "admin用户ID正确"
[ "$L" = "uid=1801(admin)" ] || echo "admin用户ID不正确"
M=`id admin | cut -d "," -f 2`
[ "$M" = "1000(ccgroup0)" ] && echo "admin用户组ID正确"
[ "$M" = "1000(ccgroup0)" ] || echo "admin用户组ID不正确"
N=`id log | cut -d " " -f 1`
[ "$N" = "uid=1802(log)" ] && echo "log用户ID正确"
[ "$N" = "uid=1802(log)" ] || echo "log用户ID不正确"
O=`id log | cut -d "," -f 4 `
[ "$O" = "1000(ccgroup0)" ] && echo "log用户组ID正确"
[ "$O" = "1000(ccgroup0)" ] || echo "log用户组ID不正确"
