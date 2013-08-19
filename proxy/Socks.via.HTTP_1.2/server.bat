@echo off
echo Socks via HTTP v1.2 Server part starting...
set CLASSPATH=classes\servlet.jar;classes\
java jhttpserver.JHttpServer -log2
pause
