#!/bin/bash

function check_install {
    if [ -z "`which "$1" 2>/dev/null`" ]
    then
        executable=$1
        shift
        while [ -n "$1" ]
        do
            DEBIAN_FRONTEND=noninteractive apt-get -q -y --force-yes install "$1"
            print_info "$1 installed for $executable"
            shift
        done
    else
        print_warn "$2 already installed"
    fi
}

function check_remove {
    if [ -n "`which "$1" 2>/dev/null`" ]
    then
        DEBIAN_FRONTEND=noninteractive apt-get -q -y remove --purge "$2"
        print_info "$2 removed"
    else
        print_warn "$2 is not installed"
    fi
}

function check_sanity {
    # Do some sanity checking.
    if [ $(/usr/bin/id -u) != "0" ]
    then
        die 'Must be run by root user'
    fi

    if [ ! -f /etc/debian_version ]
    then
        die "Distribution is not supported"
    fi
}

function die {
    echo "ERROR: $1" > /dev/null 1>&2
    exit 1
}

function get_domain_name() {
    # Getting rid of the lowest part.
    domain=${1%.*}
    lowest=`expr "$domain" : '.*\.\([a-z][a-z]*\)'`
    case "$lowest" in
    com|net|org|gov|edu|co)
        domain=${domain%.*}
        ;;
    esac
    lowest=`expr "$domain" : '.*\.\([a-z][a-z]*\)'`
    [ -z "$lowest" ] && echo "$domain" || echo "$lowest"
}

function get_password() {
    # Check whether our local salt is present.
    SALT=/var/lib/radom_salt
    if [ ! -f "$SALT" ]
    then
        head -c 512 /dev/urandom > "$SALT"
        chmod 400 "$SALT"
    fi
    password=`(cat "$SALT"; echo $1) | md5sum | base64`
    echo ${password:0:13}
}

function install_dash {
    check_install dash dash
    rm -f /bin/sh
    ln -s dash /bin/sh
}

function install_dropbear {
    check_install dropbear dropbear
    check_install /usr/sbin/xinetd xinetd

    # Disable SSH
    touch /etc/ssh/sshd_not_to_be_run
    invoke-rc.d ssh stop

    # Enable dropbear to start. We are going to use xinetd as it is just
    # easier to configure and might be used for other things.
    cat > /etc/xinetd.d/dropbear <<END
service ssh
{
    socket_type     = stream
    only_from       = 0.0.0.0
    wait            = no
    user            = root
    protocol        = tcp
    server          = /usr/sbin/dropbear
    server_args     = -i
    disable         = no
}
END
sed -i s/'NO_START=0'/'NO_START=1'/g /etc/default/dropbear

    invoke-rc.d xinetd restart
}

function install_exim4 {
    check_install mail exim4
    if [ -f /etc/exim4/update-exim4.conf.conf ]
    then
        sed -i \
            "s/dc_eximconfig_configtype='local'/dc_eximconfig_configtype='internet'/" \
            /etc/exim4/update-exim4.conf.conf
        invoke-rc.d exim4 restart
    fi
}

function install_mysql {
    # Install the MySQL packages
    check_install mysqld mysql-server
    check_install mysql mysql-client

    # Install a low-end copy of the my.cnf to disable InnoDB, and then delete
    # all the related files.
    invoke-rc.d mysql stop
    rm -f /var/lib/mysql/ib*
    cat > /etc/mysql/conf.d/lowendbox.cnf <<END
[mysqld]
key_buffer = 8M
query_cache_size = 0
skip-innodb
END
    invoke-rc.d mysql start

    # Generating a new password for the root user.
    passwd=`get_password root@mysql`
    mysqladmin password "$passwd"
    cat > ~/.my.cnf <<END
[client]
user = root
password = $passwd
END
    chmod 600 ~/.my.cnf
}

function install_nginx {
    check_install nginx nginx
    
    # Need to increase the bucket size for Debian 5.
	if [ ! -d /etc/nginx ];
        then
        mkdir /etc/nginx
	fi
	if [ ! -d /etc/nginx/conf.d ];
        then
        mkdir /etc/nginx/conf.d
	fi
    cat > /etc/nginx/conf.d/lowendbox.conf <<END
server_names_hash_bucket_size 64;
END
    sed -i s/'^worker_processes [0-9];'/'worker_processes 1;'/g /etc/nginx/nginx.conf
	invoke-rc.d nginx restart
	if [ ! -d /var/www ];
        then
        mkdir /var/www
	fi
	cat > /etc/nginx/proxy.conf <<EXND
proxy_connect_timeout 30s;
proxy_send_timeout   90;
proxy_read_timeout   90;
proxy_buffer_size    32k;
proxy_buffers     4 32k;
proxy_busy_buffers_size 64k;
proxy_redirect     off;
proxy_hide_header  Vary;
proxy_set_header   Accept-Encoding '';
proxy_set_header   Host   \$host;
proxy_set_header   Referer \$http_referer;
proxy_set_header   Cookie \$http_cookie;
proxy_set_header   X-Real-IP  \$remote_addr;
proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
EXND
}

function install_php {
    check_install php5-cli php5-mysql apache2 libapache2-mod-php5 libapache2-mod-rpaf
	sed -i s/'NameVirtualHost \*:80'/'NameVirtualHost \*:168'/g /etc/apache2/ports.conf 
	sed -i s/'Listen 80'/'Listen 168'/g /etc/apache2/ports.conf 
	cat > /etc/apache2/apache2.conf <<EXNDDQW
LockFile \${APACHE_LOCK_DIR}/accept.lock
PidFile \${APACHE_PID_FILE}
Timeout 300
KeepAlive On
MaxKeepAliveRequests 100
KeepAliveTimeout 15
<IfModule mpm_prefork_module>
    StartServers          1
    MinSpareServers       2
    MaxSpareServers       2
    MaxClients            3
    MaxRequestsPerChild   10000
</IfModule>
<IfModule mpm_worker_module>
    StartServers          2
    MinSpareThreads      25
    MaxSpareThreads      75
    ThreadLimit          64
    ThreadsPerChild      25
    MaxClients          150
    MaxRequestsPerChild   0
</IfModule>
<IfModule mpm_event_module>
    StartServers          2
    MinSpareThreads      25
    MaxSpareThreads      75
    ThreadLimit          64
    ThreadsPerChild      25
    MaxClients          150
    MaxRequestsPerChild   0
</IfModule> 
User \${APACHE_RUN_USER}
Group \${APACHE_RUN_GROUP}
AccessFileName .htaccess
DefaultType text/plain
HostnameLookups Off
ErrorLog \${APACHE_LOG_DIR}/error.log
LogLevel warn
Include mods-enabled/*.load
Include mods-enabled/*.conf
Include httpd.conf
Include ports.conf
LogFormat "%v:%p %h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" vhost_combined
LogFormat "%h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" combined
LogFormat "%h %l %u %t \"%r\" %>s %O" common
LogFormat "%{Referer}i -> %U" referer
LogFormat "%{User-agent}i" agent
Include conf.d/
Include sites-enabled/
EXNDDQW

echo "rewrite" | a2enmod
echo "alias auth_basic authn_file authz_default authz_groupfile authz_host authz_user autoindex cgi env negotiation setenvif status" | a2dismod
rm /etc/apache2/sites-enabled/000-default
/etc/init.d/apache2 restart
/etc/init.d/nginx restart
  }

function install_syslogd {
    # We just need a simple vanilla syslogd. Also there is no need to log to
    # so many files (waste of fd). Just dump them into
    # /var/log/(cron/mail/messages)
    check_install /usr/sbin/syslogd inetutils-syslogd
    invoke-rc.d inetutils-syslogd stop

    for file in /var/log/*.log /var/log/mail.* /var/log/debug /var/log/syslog
    do
        [ -f "$file" ] && rm -f "$file"
    done
    for dir in fsck news
    do
        [ -d "/var/log/$dir" ] && rm -rf "/var/log/$dir"
    done

    cat > /etc/syslog.conf <<END
*.*;mail.none;cron.none -/var/log/messages
cron.*                  -/var/log/cron
mail.*                  -/var/log/mail
END

    [ -d /etc/logrotate.d ] || mkdir -p /etc/logrotate.d
    cat > /etc/logrotate.d/inetutils-syslogd <<END
/var/log/cron
/var/log/mail
/var/log/messages {
   rotate 4
   weekly
   missingok
   notifempty
   compress
   sharedscripts
   postrotate
      /etc/init.d/inetutils-syslogd reload >/dev/null
   endscript
}
END

    invoke-rc.d inetutils-syslogd start
}

function install_vhost {
    check_install wget wget
    if [ -z "$1" ]
    then
        die "Usage: `basename $0` wordpress <hostname>"
    fi

	if [ ! -d /var/www ];
        then
        mkdir /var/www
fi
    mkdir "/var/www/$1"
    chown -R www-data "/var/www/$1"
	chmod -R 755 "/var/www/$1"

      # Setting up Nginx mapping
    cat > "/etc/nginx/sites-enabled/$1.conf" <<END
server {
    server_name $1;
    root /var/www/$1;
    location / {
        index index.html index.htm;
    }
}
END
    invoke-rc.d nginx reload
	
	cat > "/var/www/$1/index.html" <<END
Hello world!
		----$2
END
    invoke-rc.d nginx reload	
}

function install_dhost {
    check_install wget wget
	if [ ! -d /var/www ];
        then
        mkdir /var/www
	fi
    if [ -z "$1" ]
    then
        die "Usage: `basename $0` wordpress <hostname>"
    fi

    # Downloading the WordPress' latest and greatest distribution.
	mkdir "/var/www/$1"
 	chown -R www-data "/var/www/$1"
	chmod -R 755 "/var/www/$1"

   
# Setting up Nginx mapping
    cat > "/etc/nginx/sites-enabled/$1.conf" <<END
server
	{
		listen       80;
		server_name $1;
		index index.html index.htm index.php default.html default.htm default.php;
		root  /var/www/$1;

		location / {
			try_files \$uri @apache;
			}

		location @apache {
			internal;
			proxy_pass http://127.0.0.1:168;
			include proxy.conf;
			}

		location ~ .*\.(php|php5)?$
			{
				proxy_pass http://127.0.0.1:168;
				include proxy.conf;
			}

		location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
			{
				expires      30d;
			}

		location ~ .*\.(js|css)?$
			{
				expires      12h;
			}

		$al
	}
END


    invoke-rc.d nginx reload
	
	cat >/etc/apache2/conf.d/$1.conf<<eof
<VirtualHost *:168>
ServerAdmin new@qqand.info
php_admin_value open_basedir "/var/www/$1:/tmp/:/var/tmp/:/proc/"
DocumentRoot /var/www/$1
ServerName $1
</VirtualHost>
eof
/etc/init.d/apache2 restart	
}

function install_typecho {
    check_install wget wget
	if [ ! -d /var/www ];
        then
        mkdir /var/www
	fi
    if [ -z "$1" ]
    then
        die "Usage: `basename $0` wordpress <hostname>"
    fi

    # Downloading the WordPress' latest and greatest distribution.
		rm -rf /tmp/build
    wget -O - "http://typecho.googlecode.com/files/0.8(10.8.15)-release.tar.gz" | \
        tar zxf - -C /tmp/
    mv /tmp/build/ "/var/www/$1"
    rm -rf /tmp/build
 	chown -R www-data "/var/www/$1"
	chmod -R 755 "/var/www/$1"

    # Setting up the MySQL database
    dbname=`echo $1 | tr . _`
    userid=`get_domain_name $1`
    # MySQL userid cannot be more than 15 characters long
    userid="${userid:0:15}"
    passwd=`get_password "$userid@mysql"`

    mysqladmin create "$dbname"
    echo "GRANT ALL PRIVILEGES ON \`$dbname\`.* TO \`$userid\`@localhost IDENTIFIED BY '$passwd';" | \
        mysql

    # Setting up Nginx mapping

    cat > "/etc/nginx/sites-enabled/$1.conf" <<END
server
	{
		listen       80;
		server_name $1;
		index index.html index.htm index.php default.html default.htm default.php;
		root  /var/www/$1;

		location / {
			try_files \$uri @apache;
			}

		location @apache {
			internal;
			proxy_pass http://127.0.0.1:168;
			include proxy.conf;
			}

		location ~ .*\.(php|php5)?$
			{
				proxy_pass http://127.0.0.1:168;
				include proxy.conf;
			}

		location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
			{
				expires      30d;
			}

		location ~ .*\.(js|css)?$
			{
				expires      12h;
			}

		$al
	}
END

cat >> "/root/$1.mysql.txt" <<END
[wordpress_myqsl]
dbname = $dbname
username = $userid
password = $passwd
END
    invoke-rc.d nginx reload
	
	cat >/etc/apache2/conf.d/$1.conf<<eof
<VirtualHost *:168>
ServerAdmin new@qqand.info
php_admin_value open_basedir "/var/www/$1:/tmp/:/var/tmp/:/proc/"
DocumentRoot /var/www/$1
ServerName $1
</VirtualHost>
eof
/etc/init.d/apache2 restart
	
	cat >> "/root/$1.mysql.txt" <<END
[typycho_myqsl]
dbname = $dbname
username = $userid
password = $passwd
END

	echo "mysql dataname:" $dbname
	echo "mysql username:" $userid
	echo "mysql passwd:" $passwd
}

function install_wordpress_cn {
    check_install wget wget
    if [ -z "$1" ]
    then
        die "Usage: `basename $0` wordpress <hostname>"
    fi

    # Downloading the WordPress' latest and greatest distribution.
    mkdir /tmp/wordpress.$$
    wget -O - http://cn.wordpress.org/wordpress-3.1.2-zh_CN.tar.gz | \
        tar zxf - -C /tmp/wordpress.$$
    mv /tmp/wordpress.$$/wordpress "/var/www/$1"
    rm -rf /tmp/wordpress.$$
    chown -R www-data "/var/www/$1"
	chmod -R 755 "/var/www/$1"

    # Setting up the MySQL database
    dbname=`echo $1 | tr . _`
    userid=`get_domain_name $1`
    # MySQL userid cannot be more than 15 characters long
    userid="${userid:0:15}"
    passwd=`get_password "$userid@mysql"`
    cp "/var/www/$1/wp-config-sample.php" "/var/www/$1/wp-config.php"
    sed -i "s/database_name_here/$dbname/; s/username_here/$userid/; s/password_here/$passwd/" \
        "/var/www/$1/wp-config.php"
	sed -i "31a define(\'WP_CACHE\', true);"  "/var/www/$1/wp-config.php"
    mysqladmin create "$dbname"
    echo "GRANT ALL PRIVILEGES ON \`$dbname\`.* TO \`$userid\`@localhost IDENTIFIED BY '$passwd';" | \
        mysql

    # Setting up Nginx mapping
    cat > "/etc/nginx/sites-enabled/$1.conf" <<END
server
	{
		listen       80;
		server_name $1;
		index index.html index.htm index.php default.html default.htm default.php;
		root  /var/www/$1;

		location / {
			try_files \$uri @apache;
			}

		location @apache {
			internal;
			proxy_pass http://127.0.0.1:168;
			include proxy.conf;
			}

		location ~ .*\.(php|php5)?$
			{
				proxy_pass http://127.0.0.1:168;
				include proxy.conf;
			}

		location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
			{
				expires      30d;
			}

		location ~ .*\.(js|css)?$
			{
				expires      12h;
			}

		$al
	}
END

cat >> "/root/$1.mysql.txt" <<END
[wordpress_myqsl]
dbname = $dbname
username = $userid
password = $passwd
END
    invoke-rc.d nginx reload
	
	cat >/etc/apache2/conf.d/$1.conf<<eof
<VirtualHost *:168>
ServerAdmin youremail@actgod.com
php_admin_value open_basedir "/var/www/$1:/tmp/:/var/tmp/:/proc/"
DocumentRoot /var/www/$1
ServerName $1
</VirtualHost>
eof
/etc/init.d/apache2 restart
}

function install_phpmyadmin {
    check_install wget wget
    if [ -z "$1" ]
    then
        die "Usage: `basename $0` wordpress <hostname>"
    fi

    # Downloading the WordPress' latest and greatest distribution.
    mkdir /tmp/wordpress.$$
    wget -O - http://linux-bash.googlecode.com/files/phpMyAdmin.tar.gz | \
        tar zxf - -C /tmp/wordpress.$$
    mv /tmp/wordpress.$$/phpMyAdmin "/var/www/$1"
    rm -rf /tmp/wordpress.$$
    chown -R www-data "/var/www/$1"
	chmod -R 755 "/var/www/$1"

        # Setting up Nginx mapping
    cat > "/etc/nginx/sites-enabled/$1.conf" <<END
server
	{
		listen       80;
		server_name $1;
		index index.html index.htm index.php default.html default.htm default.php;
		root  /var/www/$1;

		location / {
			try_files \$uri @apache;
			}

		location @apache {
			internal;
			proxy_pass http://127.0.0.1:168;
			include proxy.conf;
			}

		location ~ .*\.(php|php5)?$
			{
				proxy_pass http://127.0.0.1:168;
				include proxy.conf;
			}

		location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
			{
				expires      30d;
			}

		location ~ .*\.(js|css)?$
			{
				expires      12h;
			}

		$al
	}
END

invoke-rc.d nginx reload
	
	cat >/etc/apache2/conf.d/$1.conf<<eof
<VirtualHost *:168>
ServerAdmin youremail@actgod.com
php_admin_value open_basedir "/var/www/$1:/tmp/:/var/tmp/:/proc/"
DocumentRoot /var/www/$1
ServerName $1
</VirtualHost>
eof
/etc/init.d/apache2 restart

cat ~/.my.cnf
}


function print_info {
    echo -n -e '\e[1;36m'
    echo -n $1
    echo -e '\e[0m'
}

function print_warn {
    echo -n -e '\e[1;33m'
    echo -n $1
    echo -e '\e[0m'
}

function remove_unneeded {
    # Some Debian have portmap installed. We don't need that.
    check_remove /sbin/portmap portmap

    # Remove rsyslogd, which allocates ~30MB privvmpages on an OpenVZ system,
    # which might make some low-end VPS inoperatable. We will do this even
    # before running apt-get update.
    check_remove /usr/sbin/rsyslogd rsyslog

    # Other packages that seem to be pretty common in standard OpenVZ
    # templates.
    check_remove /usr/sbin/apache2 'apache2*'
    check_remove /usr/sbin/named bind9
    check_remove /usr/sbin/smbd 'samba*'
    check_remove /usr/sbin/nscd nscd

    # Need to stop sendmail as removing the package does not seem to stop it.
    if [ -f /usr/lib/sm.bin/smtpd ]
    then
        invoke-rc.d sendmail stop
        check_remove /usr/lib/sm.bin/smtpd 'sendmail*'
    fi
}

function update_upgrade {
    # Run through the apt-get update/upgrade first. This should be done before
    # we try to install any packagec
cp	/etc/apt/sources.list /etc/apt/sources.list.backup
cat >> /etc/apt/sources.list <<END
deb http://ftp.de.debian.org/debian wheezy main
END
    apt-get -q -y update
    apt-get -q -y upgrade
}

function shengji {
cat >> /etc/apt/sources.list <<END
deb http://ftp.us.debian.org/debian lenny main contrib non-free
deb http://ftp.debian.org/debian lenny main contrib non-free
deb http://volatile.debian.org/debian-volatile lenny/volatile main contrib non-free
deb http://security.debian.org/ lenny/updates main contrib non-free
deb http://packages.dotdeb.org stable all
deb-src http://packages.dotdeb.org stable all
END
wget http://www.dotdeb.org/dotdeb.gpg
cat dotdeb.gpg | apt-key add -

cat > ./restart.sh <<END
#!/bin/bash
invoke-rc.d nginx restart
invoke-rc.d php-cgi restart
invoke-rc.d mysql restart
END
invoke-rc.d nginx stop
#~ cat >> /etc/apt/sources.list <<END
#~ deb http://ftp.us.debian.org/debian sid main
#~ END

apt-get -y update
apt-get -y install nginx
sed -i s/'^worker_processes [0-9];'/'worker_processes 1;'/g /etc/nginx/nginx.conf

if [ ! -d /var/www ];
        then
        mkdir /var/www
fi
#~ sed -i '$d' /etc/apt/sources.list
apt-get -y update
apt-get -y upgrade
apt-get -f install -y
bash ./restart.sh
}
########################################################################
# START OF PROGRAM
########################################################################
export PATH=/bin:/usr/bin:/sbin:/usr/sbin

check_sanity
case "$1" in
exim4)
    install_exim4
	;;
mysql)
    install_mysql
	;;
nginx)
    install_nginx
	;;
php)
    install_php
	;;
system)
    remove_unneeded
    update_upgrade
    install_dash
    install_syslogd
    install_dropbear
    ;;
typecho)
    install_typecho $2
    ;;
dhost)
    install_dhost $2
    ;;
wordpress)
    install_wordpress_cn $2
    ;;
ss5)
    wget http://linux-bash.googlecode.com/files/ss5.sh
	bash ss5.sh
	;;
all)
	remove_unneeded
    update_upgrade
    install_dash
    install_syslogd
    install_dropbear
    install_exim4
    install_mysql	
    install_nginx
    install_php
		;;
addnginx)
    sed -i s/'^worker_processes [0-9];'/'worker_processes iGodactgod;'/g /etc/nginx/nginx.conf
	sed -i s/iGodactgod/$2/g /etc/nginx/nginx.conf
	invoke-rc.d nginx restart
	;;
ssh)
    cat >> /etc/shells <<END
/sbin/nologin
END
useradd $2 -s /sbin/nologin
echo $2:$3 | chpasswd 
    ;;
httpproxy)
    cat > /etc/nginx/sites-enabled/httpproxy.conf <<END
	server {
	listen $2;
	resolver 8.8.8.8;
	location / {
	proxy_pass http://\$http_host\$request_uri;
		}
	}
END
	invoke-rc.d nginx restart
	;;
*)
    echo 'Usage:' `basename $0` '[option]'
    echo 'Available option:'
    for option in system exim4 mysql nginx php wordpress typecho ssh addnginx all dhost httpproxy
    do
        echo '  -' $option
    done
    ;;
esac