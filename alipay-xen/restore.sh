cd /root/backup/
 rsync -avzP network   /etc/sysconfig/network
 rsync -avzP network-scripts   /etc/sysconfig/
 rsync -avzP modprobe.conf  /etc/modprobe.conf
 rsync -avzP xen   /etc/
