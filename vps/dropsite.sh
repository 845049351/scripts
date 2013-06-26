#!/bin/bash

# add line to /etc/crontab
# 0 0 * * 1 user /bin/bash dropsite.sh site.com username password /backup .

cat <<EOF

**************************
* DROP SITE VERSION 1.0  *
**************************

EOF

if [ "$5" == "" ];then
  echo "usage: $0 site user passwd ldir rdir"
  exit
fi

SITE=$1
USER=$2
PASSWD=$3
LDIR=$4
RDIR=$5

echo "PARAM LIST
==============
SITE=$SITE
USER=$USER
LDIR=$LDIR
RDIR=$RDIR
"

echo "STEP[1] : prepare to drop site $SITE"

rm -rf $LDIR
mkdir -p $LDIR
cd $LDIR

echo "STEP[2] : begin drop"
ftp -n<<EOF
open $SITE
user $USER $PASSWD
binary
cd  $RDIR
lcd $LDIR
prompt
mget *
close
bye
EOF

echo "STEP[3]: finished $?"
echo ""
echo "COPIED FILE LIST"
echo "======================="
ls -al $LDIR
