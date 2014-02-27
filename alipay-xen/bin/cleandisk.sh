#!/bin/sh
# this line is only for change file size
HOST=`hostname`
HOSTGROUP=`hostname |sed 's/-\|[0-9]\+//g'`
LOGPATHPAY="/home/admin/logs/apache/ /home/admin/logs/jboss/ /home/admin/logs/$HOST/ /home/admin/logs/agent"
LOGPATHBOUNCE="/tmp /var/log/ /home/iron/DeliveryLogs/ /home/iron/qmail_logs/  /home/iron/mail_logs/ /home/vpopmail/domains/mail.alipay.net/mailmaster/Maildir/ /home/vpopmail/domains/mail.alipay.com/service/Maildir/ /home/vpopmail/domains/mail.alipay.com/alipay/Maildir/"

case  $HOSTGROUP in
	bounce) /usr/bin/find  $LOGPATHBOUNCE -mtime +3 -type f |xargs rm -f ;
		/usr/bin/find /home/vpopmail/domains/mail.alipay.com/ -mmin +5 -type f  -mindepth 3|xargs rm -f  ;
		/usr/bin/find /home/vpopmail/domains/dm.mail.alipay.com/operating/ -mmin +5 -type f  -mindepth 3|xargs rm -f  ;
		/usr/bin/find /var/log/ -name maillog.\* -type f |xargs rm -f;
		/usr/bin/find /var/ironlog/ -mtime +7 -type f |xargs rm -f ;
		/usr/bin/find /home/alimama -mtime +3 -type f |xargs rm -f ;
		/usr/bin/find /home/iron/DeliveryLogs/ -mtime +3 -type f |xargs rm -f ;
		/usr/bin/find /home/iron/mail_logs/ -mtime +1 -type f |xargs rm -f ;
		/usr/bin/find /home/iron/qmail_logs/ -mtime +1 -type f |xargs rm -f ;
			;;
	ctu|bops|bopstask|payadmin|forumweb|image|bopsam|charge|bopsam|mktadpub|mktpub|mkt|mktmng|point|pointtask|yzt|katong|process|smsgw|audit|counter|wap|mipgw|mapi|prodtrans|ivrgw|settlecore|paycore|aliapi|godzilla|mktcust|certify|cpa|mobile|settleprod|enterprise|mibap|aliprod|ctutask)
		/usr/bin/find  $LOGPATHPAY -mtime +14 -size +1c -name \*200\* -type f |xargs rm -f ;  
		/usr/bin/find /home/admin/logs/apache/ -mtime +6 -name \jk.log.\* -type f | xargs rm -f ;
	;;
        cif|acctrans)
                /usr/bin/find  $LOGPATHPAY -mtime +14 -size +1c -name \*200\* -type f |xargs rm -f ;
                /usr/bin/find /home/admin/logs/apache/ -mtime +6 -name \jk.log.\* -type f | xargs rm -f ;
                /bin/rm -f /home/admin/logs/$HOST/sofa-esb-http.log.2009*
        ;;
        paygw|certify)
                /usr/bin/find  $LOGPATHPAY -mtime +30 -size +1c -name \*200\* -type f |xargs rm -f ;
                /usr/bin/find /home/admin/logs/apache/ -mtime +20 -name \jk.log.\* -type f | xargs rm -f ;   
        ;;   
        pay)
              #  /bin/mkdir /home/admin/logs/back_30d ;
                /bin/cp -f /home/admin/logs/$HOST/beyond-trade.log.* /home/admin/logs/back_30d/ ;
                /usr/bin/find /home/admin/logs/back_30d/ -mtime +50 -type f | xargs rm -f ;
                /usr/bin/find  $LOGPATHPAY -mtime +14 -size +1c -name \*200\* -type f |xargs rm -f ;
                /usr/bin/find /home/admin/logs/apache/ -mtime +6 -name \jk.log.\* -type f | xargs rm -f ;
        ;;
        trade)
               # /bin/mkdir /home/admin/logs/back_30d ;
               /bin/cp -f /home/admin/logs/$HOST/tradecore-integration-info.log.* /home/admin/logs/back_30d/ ; 
               /usr/bin/find /home/admin/logs/back_30d/ -mtime +50 -type f | xargs rm -f ;
               /usr/bin/find  $LOGPATHPAY -mtime +14 -size +1c -name \*200\* -type f |xargs rm -f ;
               /usr/bin/find /home/admin/logs/apache/ -mtime +6 -name \jk.log.\* -type f | xargs rm -f ;
               /bin/rm -f /home/admin/logs/$HOST/sofa-esb-http.log.2009* 
        ;;
	paytask) 
               /bin/cp -f /home/admin/logs/$HOST/beyond-trade.log* /home/admin/logs/back_30d/ ;  
               /usr/bin/find /home/admin/logs/back_30d/ -mtime +50 -type f | xargs rm -f ;
               /usr/bin/find  $LOGPATHPAY -mtime +14 -size +1c -name \*200\* -type f |xargs rm -f
               /usr/bin/find /home/admin/logs/apache/ -mtime +6 -name \jk.log.\* -type f | xargs rm -f ;
	;;
        mktfront|promo|accore|help|mktcust|countcore)
                /usr/bin/find  $LOGPATHPAY -mtime +4 -size +1c -name \*200\* -type f |xargs rm -f ;
                /usr/bin/find /home/admin/logs/apache/ -mtime +3 -name \jk.log.\* -type f | xargs rm -f 
        ;;
        pointcore)
           /usr/bin/find  $LOGPATHPAY -mtime +0 -size +1c -name \*200\* -type f |xargs rm -f ;
           /usr/bin/find /home/admin/logs/apache/ -mtime +1 -name \jk.log.\* -type f | xargs rm -f
        ;;
        bankgw)
               /usr/bin/find  $LOGPATHPAY -mtime +14 -size +1c -name \*200\* -type f |xargs rm -f ;
               /usr/bin/find  /home/admin/logs/bank -mtime +30 -size +1c -name \*200\* -type f |xargs rm -f ;
               /usr/bin/find /home/admin/logs/apache/ -mtime +6 -name \jk.log.\* -type f | xargs rm -f
               /usr/bin/find /home/admin/logs/$HOST/ -mtime +30 -type f | xargs rm -f;
        ;;
	ca)
		/usr/bin/find /home/admin/logs -mtime +21  -type f -size +1c | xargs rm -f
	;;
        forumsearch)
               /usr/bin/find /home/admin/bangbang/logs -mtime +6 -type f | xargs rm -f;
        ;;
	caapp)
		/usr/bin/find /home/admin/logs/qmlog/ -mtime +90  -type f -size +1c | xargs rm -f

	;;
        bdcrm)
                /usr/bin/find  $LOGPATHPAY -mtime +31 -size +1c -name \*200\* -type f |xargs rm -f ;
                /usr/bin/find /home/admin/logs/apache/ -mtime +15 -name \jk.log.\* -type f | xargs rm -f ;

        ;;
	yzt|yztems)
		                /usr/bin/find  $LOGPATHPAY -mtime +30 -size +1c -name \*200\* -type f |xargs rm -f ;
	;;
	*) exit 0 ;;
esac
	
