#!/bin/sh
export ANTX_HOME=/opt/taobao/antx
export JAVA_HOME=/opt/taobao/java
SVN=/usr/local/bin/svn
[ -e /usr/local/bin/svn ] || SVN=/usr/bin/svn
$SVN info /opt/taobao/antx 2> /dev/null | grep 'trunk'
if [ $? -eq 0 ]; then
    $SVN up --username 'test' --password 'xixihaha' /opt/taobao/antx
else
    rm -rf /opt/taobao/antx 2> /dev/null
    $SVN co --username 'test' --password 'xixihaha' http://sources.alipay.net/svn/antx/trunk /opt/taobao/antx
fi
cd /opt/taobao/antx
/bin/sh build.sh
