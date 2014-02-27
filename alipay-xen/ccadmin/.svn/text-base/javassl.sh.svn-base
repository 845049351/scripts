#!/bin/sh
JAVA_HOME=/opt/taobao/java
$JAVA_HOME/bin/keytool -import -noprompt -trustcacerts -alias $1 -file /root/ccadmin/ssl/$1.cer -keystore $JAVA_HOME/jre/lib/security/cacerts -storepass changeit
