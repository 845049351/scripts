#!/bin/bash
# cat > /etc/apt/sources.list <<END
# deb http://ftp.us.debian.org/debian stable main contrib non-free
# deb-src http://ftp.us.debian.org/debian stable main contrib non-free
# END
apt-get -q -y update
apt-get -y -q install automake make gcc g++
wget http://nchc.dl.sourceforge.net/project/kingate/kingate/2.0/kingate-2.0.tar.gz
tar xzf kingate-2.0.tar.gz
cd kingate-2.0
./configure --prefix=/etc/kingate
make install
cat >/etc/kingate/etc/kingate.conf << eof
http off
ftp off
pop3 off
smtp off
telnet off
socks on
mms off
rtsp off
manage off
max 2000
max_per_ip 0
min_free_thread 3
http_port 8082
http_accelerate off
x_forwarded_for on
http_time_out 30
ftp_port 2121
ftp_time_out 300
pop3_port 1100
pop3_time_out 300
smtp_port 2525
smtp_time_out 300
telnet_port 2323
telnet_time_out 300
socks_port 60321
socks_time_out 300
socks5_user off
mms_port 1755
mms_time_out 300
rtsp_port 5540
rtsp_time_out 300
manage_port 2222
manage_time_out 300
log_model user
log_level 0
log_rotate {0 0 * * * }
log_close_msg on
mem_min_cache 50m
mem_max_cache 12m
disk_min_cache 20m
disk_max_cache 30m
use_disk_cache off
refresh never
refresh_time 300
user_time_out 0
mem_cache 50m
disk_cache 100m
max_deny_per_ip 0
max_queue_thread 15
min_limit_speed_size 1m
limit_speed 20k
max_request 50
total_seconds 10
bind_addr
run_user
insert_via off
eof
/etc/kingate/bin/kingate
sed -i '2a /etc/kingate/bin/kingate'  /etc/rc.local