#!/bin/bash

echo "Cliente"

PORT=2021
IP_CLIENT="127.0.0.1"

if [ "$1" == "" ]; then
	IP_SERVER="127.0.0.1"
else
	IP_SERVER="$1"
fi

OK="OK_CONN"
KO="KO_CONN"
YES="YES_IT_IS"
OK_FILE="OK_FILE_NAME"
OK_DATA="OK_DATA"
FILE_NAME="archivo_salida.vaca"

echo "(2) Seanding headers to $IP_SERVER"

echo "ABFP $IP_CLIENT" | nc -q 1 $IP_SERVER $PORT

echo "(3) Listening"

RESPONSE=`nc -l -p $PORT`

if [ "$RESPONSE" != $OK ]; then
	echo "Error: Connection refused"
	exit 1
fi

echo "(6) Handshake"

sleep 1
echo "THIS_IS_MY_CLASSROOM" | nc -q 1 $IP_SERVER $PORT

echo "(7a) Listening HANDSHAKE RESPONSE..."

RESPONSE=`nc -l -p $PORT`
if [ "$RESPONSE" != $YES ]; then
	echo "Handshake fallido"
	exit 2
fi

echo "(7b) SENDING NUM_FILES"
sleep 1
NUM_FILES =`ls $INPUT_PATH | wc -w`
echo "NUM_FILES NUM_FILES" | nc -q 1 $IP_SERVER $PORT

echo "(7c) Listen"
RESPONSE=`nc -l -p $PORT`
if [ "$RESPONSE" != "OK_NUM_FILES" ]; then
	echo "ERROR: NUM_FILES incorrecto"
	exit 2
fi

for FILE_NAME in `ls $INPUT_PATH`; do
	FILE_MD5= `echo $FILE_NAME | md5sum | cut -d " " -f 1`
	
	echo "(10 Sending File"
	sleep 1
	echo "File_NAME $FILE_NAME $FILE_MD5" | nc -q 1 $IP_SERVER $PORT

	echo "(11) Listening FILE_NAME RESPONSE"
	RESPONSE = `nc -l -p $PORT`
	if [ "$RESPONSE" != "OK_FILE_NAME" ]; then
		echo "ERROr: CORRUPT FILE"
		exit 3
	fi
	sleep 1
	cat "$INPUT_PATH$FILE_NAME" | nc -q 1 $IP_SERVER $PORT
done


echo "(14) Data"

sleep 1
cat $FILE_NAME | nc -q 1 $IP_SERVER $PORT

echo "(15) Listening"

RESPONSE=`nc -l -p $PORT`
if [ "$RESPONSE" != $OK_DATA ]; then
	echo "Error: data sended failed"
	exit 4
fi

echo "(18) Goodbye"

sleep 1
echo "ABFP GOOD_BYE" | nc -q 1 $IP_SERVER $PORT
exit 0
