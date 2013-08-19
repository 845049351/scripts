#!/bin/sh
echo Socks via HTTP v1.2 Client part starting...
export CLASSPATH=classes/servlet.jar:classes/
java socksviahttp.client.Client -log2
