GET_CHAR()
{
SAVEDSTTY=`stty -g`
stty -echo
stty raw
dd if=/dev/tty bs=1 count=1 2> /dev/null
stty -raw
stty echo
stty $SAVEDSTTY
}
HELP_RUN(){
echo "Usage: adduser [username]"
echo "ִ������:1.����û� -> 2.�����û����� -> 3.����Ȩ�� -> 4.��������"
}
if [ -z $1 ];then
    HELP_RUN
    exit
fi
## 1
echo -e "\033[1m1.����û�\033[0m -> 2.�����û����� -> 3.����Ȩ�� -> 4.��������"
echo -n "�밴���������..."
char=`GET_CHAR`
echo ""
echo "����û����"
## 2
echo ""
echo -e "1.����û� -> \033[1m2.�����û�����\033[0m -> 3.����Ȩ�� -> 4.��������"
result=`nohup /usr/local/apache2/bin/htpasswd /home/svn/svnfiles/passwd $1`
errmsg="password verification error"
errtimes=0
while [ "${result:(-${#errmsg})}" = "$errmsg" ];do
    echo "������������벻ƥ��"
    errtimes=$[$errtimes+1]
    if [ $errtimes -ge 3 ];then
        echo "��������3���������"
        exit
    fi
    result=`nohup /usr/local/apache2/bin/htpasswd /home/svn/svnfiles/passwd $1`
done
echo "�����û��������"
##3
echo ""
echo -e "1.����û� -> 2.�����û����� -> \033[1m3.����Ȩ��\033[0m -> 4.��������"
echo -n "�밴���������..."
char=`GET_CHAR`
vi /home/svn/svnfiles/auth.conf
echo ""
echo "����Ȩ�����"
##?
echo -n "�Ƿ�Ҫ����������Ч?[Y/N]"
char=`GET_CHAR`
if [ $char = "N" ];then
    exit
fi
if [ $char = "n" ];then
    exit
fi
##4
echo ""
echo -e "1.����û� -> 2.�����û����� -> 3.����Ȩ�� -> \033[1m4.��������\033[0m"
echo "����������Ҫʹ��rootȨ��ִ��,������rootȨ�޵�����"

errtimes=0
su -c "/usr/local/apache2/bin/apachectl restart" root
statue=$?
while [ $statue -ne 0 ];do
    errtimes=$[$errtimes+1]
    if [ $errtimes -ge 3 ];then
        echo "��������3���������"
        exit
    fi
    su -c "/usr/local/apache2/bin/apachectl restart" root
    statue=$?
done
echo "���������������"
exit
