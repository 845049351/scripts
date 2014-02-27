#!/bin/bash
# This shell is used to initialize app system
# jian.song@alipay.com 2012/3/21
##################################################################
echo "****************************************************"
echo "* Initializing"
echo "* DATE: `date '+%F %T'`"
echo "`hostname`"
echo "****************************************************"

USER=admin
ID=1801

# SYSTEM_FILE
echo -e "\n Restore hosts and resolv.conf"
svn co "http://sources.alipay.net/svn/docs/trunk/SCM/src/ccadmin" /root/ccadmin --username "test" --password "xixihaha" > /dev/null
cp -f /root/ccadmin/files/hosts /etc/hosts
chown root.root /etc/hosts
cp -f /root/ccadmin/files/resolv.conf /etc/resolv.conf

# Kill httpd and java
echo -e "\n Kill java and httpd"
killall httpd
killall java

#踢除登录用户
pkill -u admin,log

# crontab
echo -e "\n Clean crontab"
cronfile="/var/spool/cron/$USER"
cat /dev/null > $cronfile

# create group; -f: 如果组已存在则退出
echo -e "\n Create groups from ccgroup0"
groupadd -g 1000 -f ccgroup0

# clean /home/$USER/*
echo -e "\n Clean /home/$USER/*"

if [ "$1" == "force" ];then
	ssh_key="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA3ejiS+sMF4EtFkYkDluuEUX6W00VbESP3cKY3p5CHSr1udnXVvB/d3aQk/iruSrm8T14T+LSPGZ614nxIbHjh+yOVsNN53z19wba1cyCaufzo2P5ycN+9Lm4X7ZWXvaX3BamdaJPnWKCDUDSfqXPMIyTxYsVjT1VQDKABgODlsCo0ab+D6Osv4eQBrJJRfKS6TfvrAdha9YnsHf1hxLJ/a/SjNgXQ0xN7obOZSsqvQG7zj4VKbfZmBnrY6YDrFEF15Fh9B5cRoEMQU+TqySaU7cXIEPrgX5WMPACAxWryHQ8O/6Gkn7s0qpDwel81ltpRuPn4rRVgIV1ZIcagdJoiw== admin@bsldb-1-1"
	# DEL USER
	userdel -rf $USER
	#ADD USER
	useradd -u $ID -g ccgroup0 $USER
	cd /home/$USER/
	[ ! -d ".ssh" ] && mkdir .ssh
	echo "$ssh_key" >> .ssh/authorized_keys
	svn co "http://sources.alipay.net/svn/docs/trunk/SCM/src/ccbin/" /home/$USER/ccbin --username "test" --password "xixihaha" > /dev/null
else
	usermod -u $ID -g ccgroup0 $USER
	rm -rf /home/$USER/cccbin
	svn co "http://sources.alipay.net/svn/docs/trunk/SCM/src/ccbin/" /home/$USER/ccbin --username "test" --password "xixihaha" > /dev/null
fi


#改变文件夹权限
chown -R $USER:ccgroup0 /home/$USER/
chmod 755 /home/$USER


echo "****************************************************"
echo "* Initialize done ~~~~~"
echo "* DATE: `date '+%F %T'`"
echo "****************************************************"
