@echo off
echo Socks via HTTP v1.2 Client part starting...
set CLASSPATH=classes\servlet.jar;classes\
java socksviahttp.client.Client -log2
pause
