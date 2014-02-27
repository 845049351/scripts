[ -d  /root/backup/ ] || mkdir /root/backup
cd /root/backup/ 

 rsync -avzP  /etc/sysconfig/network /root/backup/
 rsync -avzP  /etc/sysconfig/network-scripts  /root/backup/
 rsync -avzP  /etc/modprobe.conf /root/backup/
 rsync -avzP  /etc/xen           /root/backup/
