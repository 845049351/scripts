#!/bin/bash
if [ -z $1 ]; then
	echo "Useage: download id";
	exit 1;
fi
if [ ! -d "/opt/bookshelf/books/$1" ]; then
	echo "不存在目录 /opt/bookshelf/books/$1";
	exit 1;
fi
cd /opt/bookshelf/books/$1
curl -s http://book.mvnsearch.org/book/show.part?id=$1 > /opt/bookshelf/temp.html
urls=$(grep "/book/download.action" /opt/bookshelf/temp.html | sed "s/\(.*\)book\/download.action?\(.*\)\">\(.*\)/\2/g");
for value in ${urls[*]}
do
echo "[$1] wget --header=\"Referer: http://book.mvnsearch.org/\" --content-disposition http://book.mvnsearch.org/book/download.action?$value" >> /opt/bookshelf/dl.log
wget --header="Referer: http://book.mvnsearch.org/" --content-disposition http://book.mvnsearch.org/book/download.action?$value
done
rm -rf /opt/bookshelf/books-record/$1
