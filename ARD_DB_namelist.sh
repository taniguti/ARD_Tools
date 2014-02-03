#!/bin/sh
# taniguchi.takanori@dena.jp

LISTFILE="$1"
info=0
isEND=no
PB="/usr/libexec/PlistBuddy"

if [ $# -lt 1 ]; then
	echo "Need plist file."; exit 0
fi
if [ ! -f "$LISTFILE" ]; then
	echo "File not found."; exit 0	
fi

while [ $isEND = no ] 
do
	$PB -c "print items:$info" "$LISTFILE" > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		objname=`$PB -c "print items:$info:name" "$LISTFILE" 2> /dev/null`
		echo "$objname"
	else
		isEND=yes
	fi
	info=`expr $info + 1`
done
