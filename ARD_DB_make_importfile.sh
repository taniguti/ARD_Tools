#!/bin/sh
# taniguchi.takanori@dena.jp

if [ ! -f  "$1" ]; then echo "I need a file."; exit 0; fi

GET_IPADDR(){
	OCT3=`echo $((RANDOM % 254 ))`
	OCT4=`echo $((RANDOM % 254 ))`
	IPADDR="169.254.${OCT3}.${OCT4}"
	echo $IPADDR
}

ADD_ENTRY(){
	n=$1
	macname=$2
	macaddr=$3
	pfile=$4
	netaddr=`GET_IPADDR`

	/usr/libexec/PlistBuddy -c "add items:${n}:name            string  $macname" "$pfile"
	/usr/libexec/PlistBuddy -c "add items:${n}:hardwareAddress string  $macaddr" "$pfile"
	/usr/libexec/PlistBuddy -c "add items:${n}:networkaddress  string  $netaddr" "$pfile"
	/usr/libexec/PlistBuddy -c "add items:${n}:networkPort     integer 3283"     "$pfile"
	/usr/libexec/PlistBuddy -c "add items:${n}:vncPort         integer 5900"     "$pfile"
	/usr/libexec/PlistBuddy -c "add items:${n}:preferHostname  bool    false"    "$pfile"
}

num=0
LINE_NUM=1
TUUID=`uuidgen`
WDIR="/tmp/$TUUID"
CHKHOST=$WDIR/hostnames
CHKMAC=$WDIR/macaddrs
IMPORT_LISTNAME="LIST_Of_`date +%Y-%b-%d`"
IMPORTFILE=$WDIR/${IMPORT_LISTNAME}_${TUUID}.plist
OUTPUTDIR=`dirname "$1"`

mkdir $WDIR
touch $CHKHOST
touch $CHKMAC
/usr/libexec/PlistBuddy -c "add listName string $IMPORT_LISTNAME" "${IMPORTFILE}" > /dev/null
/usr/libexec/PlistBuddy -c "add uuid     string $TUUID"           "${IMPORTFILE}" > /dev/null
/usr/libexec/PlistBuddy -c "add items    array"                   "${IMPORTFILE}" > /dev/null

cat "$1" | while read LINE
do
	/bin/echo -n "${LINE_NUM}: "
	omacname=`echo $LINE | awk -F, '{print $1}'`
	lmacname=`echo "$omacname" | tr [:upper:] [:lower:]`

	omacaddr=`echo $LINE | awk -F, '{print $2}'`
	lmacaddr=`echo "$omacaddr" | tr [:upper:] [:lower:]`

	if [ X${lmacname} = X ]; then	
		HCHK='-1'
	else
		HCHK=`grep -c "$lmacname" $CHKHOST`
	fi
	if [ $HCHK -eq 0 ]; then
		echo "$lmacname" >> $CHKHOST
		/bin/echo -n "$lmacname "
		HSTATE=0
	else
		if [ $HCHK -eq '-1' ]; then
			echo "line:$LINE_NUM: hostname is empty." >> $WDIR/dup_hostname.txt
			/bin/echo -n "empty "
		else
			echo "line:$LINE_NUM: $omacname is duplicated." >> $WDIR/dup_hostname.txt
			/bin/echo -n "$lmacname(DUP!) "
		fi
		HSTATE=1
	fi

	if [ X${lmacaddr} = X ]; then	
		MCHK='-1'
	else
		MCHK=`grep -c "$lmacaddr" $CHKMAC`
	fi
	if [ $MCHK -eq 0 ]; then
		echo "$lmacaddr" >> $CHKMAC
		/bin/echo -n "$lmacaddr "
		MSTATE=0
	else
		if [ $MCHK -eq '-1' ]; then
			echo "line:$LINE_NUM: MAC is empty." >> $WDIR/dup_macaddr.txt
			/bin/echo -n "empty "
		else
			echo "line:$LINE_NUM: $omacaddr is duplicated." >> $WDIR/dup_macaddr.txt
			/bin/echo -n "$lmacaddr(DUP!) "
		fi
		MSTATE=1
	fi
	
	if [ `expr $HSTATE + $MSTATE` -eq 0 ]; then STATE=OK ; fi
	if [ ${STATE:=NG} = OK ]; then
		ADD_ENTRY "$num" "$lmacname" "$lmacaddr" "$IMPORTFILE"	
		num=`expr $num + 1`
	fi

	/bin/echo  " $STATE"

	LINE_NUM=`expr $LINE_NUM + 1`
	unset HCHK MCHK HSTATE MSTATE STATE
done

echo ""
if [ -w "$OUTPUTDIR" ]; then
	mv "$IMPORTFILE" "$OUTPUTDIR"
else
	echo "Import file is here: $IMPORTFILE"
fi
for f in $WDIR/dup_hostname.txt $WDIR/dup_macaddr.txt 
do
	if [ -f $f ]; then cat $f ; fi
done
