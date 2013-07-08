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
echo "执行流程:1.添加用户 -> 2.设置用户密码 -> 3.配置权限 -> 4.重启服务"
}
if [ -z $1 ];then
    HELP_RUN
    exit
fi
## 1
echo -e "\033[1m1.添加用户\033[0m -> 2.设置用户密码 -> 3.配置权限 -> 4.重启服务"
echo -n "请按任意键继续..."
char=`GET_CHAR`
echo ""
echo "添加用户完成"
## 2
echo ""
echo -e "1.添加用户 -> \033[1m2.设置用户密码\033[0m -> 3.配置权限 -> 4.重启服务"
result=`nohup /usr/local/apache2/bin/htpasswd /home/svn/svnfiles/passwd $1`
errmsg="password verification error"
errtimes=0
while [ "${result:(-${#errmsg})}" = "$errmsg" ];do
    echo "两次输入的密码不匹配"
    errtimes=$[$errtimes+1]
    if [ $errtimes -ge 3 ];then
        echo "密码连续3次输入错误"
        exit
    fi
    result=`nohup /usr/local/apache2/bin/htpasswd /home/svn/svnfiles/passwd $1`
done
echo "设置用户密码完成"
##3
echo ""
echo -e "1.添加用户 -> 2.设置用户密码 -> \033[1m3.配置权限\033[0m -> 4.重启服务"
echo -n "请按任意键继续..."
char=`GET_CHAR`
vi /home/svn/svnfiles/auth.conf
echo ""
echo "配置权限完成"
##?
echo -n "是否要重启服务生效?[Y/N]"
char=`GET_CHAR`
if [ $char = "N" ];then
    exit
fi
if [ $char = "n" ];then
    exit
fi
##4
echo ""
echo -e "1.添加用户 -> 2.设置用户密码 -> 3.配置权限 -> \033[1m4.重启服务\033[0m"
echo "以下命令需要使用root权限执行,请输入root权限的密码"

errtimes=0
su -c "/usr/local/apache2/bin/apachectl restart" root
statue=$?
while [ $statue -ne 0 ];do
    errtimes=$[$errtimes+1]
    if [ $errtimes -ge 3 ];then
        echo "密码连续3次输入错误"
        exit
    fi
    su -c "/usr/local/apache2/bin/apachectl restart" root
    statue=$?
done
echo "服务重新启动完成"
exit
