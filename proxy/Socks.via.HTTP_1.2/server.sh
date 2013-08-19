#!/bin/sh
echo Socks via HTTP v1.2 Server part starting...
export CLASSPATH=classes/servlet.jar:classes/
java jhttpserver.JHttpServer -log2
