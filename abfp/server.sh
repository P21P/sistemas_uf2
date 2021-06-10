#!/bin/bash
PORT=2021
OUTPUT_PATH="server_output/"

echo "(0) Server ABFP"

echo "(1) Listening ($PORT) Headers"

HEADER= `nc -l -p $PORT`
echo "ABFP TESTIng $HEADER"

PREFIX= `echo $HEADER | cut -d " " -f 1`
IP_CLIENT=`echo $HEADER | cut -d " " -f 2`

echo "(4) Response"
if [ "$PREFIX" != "ABFP" ]; then
	echo "ERROR: IN HEADER"
	sleep 1
	echo "KO_CONN" | nc -q 1 $IP_CLIENT $PORT

	exit 1
fi
sleep 1
echo "OK_CONN" | nc -q 1 $IP_CLIENT $PORT

echo "(5) Listening Test"
HANDSHAKE=`nc -l -p $PORT`
echo "Handshake testing $HANDSHAKE"

echo "(8) Response"
if [ "$HANDSHAKE" != "THIS_IS_MY_CLASSROOM" ]; then
	echo "ERROR Handshake"
	sleep 1
	echo "KO_HANDSHAKE" | nc -q 1 $IP_CLIENT $PORT
fi
sleep 1
echo "YES_IT_IS" | nc -q 1 $IP_CLIENT $PORT

echo "(8b) Listen NUM_FILES"

NUM_FILES=`nc -l -p $PORT`
PREFIX=`echo $NUM_FILES | cut -d " " -f 1`
NUM=`echo $NUM_FILES | cut -d " " -f 2`

if [ "$PREFIX" != "NUM_FILES" ]; then
	echo "ERROR: NUM_FILES incorrecto"
	sleep 1
	echo "KO_NUM_FILES" | nc -q 1 $IP_CLIENT $PORT
	
	exit 2
fi

sleep 1
echo "OK_NUM_FILES" | nc -q 1 $IP_CLIENT $PORT
echo "NUM_FILES: $NUM"

for NUMBER in `seq $NUM`; do
	echo "(9) Listening"
	FILE_NAME= `nc -l -p $PORT`

	PREFIX=`echo $FILE_NAME | cut -d " " -f 1`
	NAME=`echo $FILE_NAME | cut -d " " -f 2`
	NAME_MD5=`echo $FILE_NAME | cut -d " " -f 3`

	if [ "$PREFIX" != "FILE_NAME" ]; then
		echo "ERROR  in FILE_NAME"
		sleep 1
		echo "KO_FILE_NAME" | nc -q 1 $IP_CLIENT $PORT
		exit 3
	fi
	TEMP_MD5=`echo $NAME | md5sum |cut -d " " -f 1`

	if [ "$NAME_MD5" != "$TEMP_MD5" ]; then
		echo "ERROR in FILE_NAME"
		sleep 1
		echo "KO_FILE_NAME" | nc -q 1 $IP_CLIENT $PORT
		exit 4
	fi

	echo "(12) FILE_NAME($NAME) Response"
	sleep 1
	echo "OK_FILE_NAME" | nc -q 1 $IP_CLIENT $PORT
	echo $OUTPUT_PATH$NAME

	nc -l -p $PORT > $OUTPUT_PATH$NAME
done
echo "(13) Listening"
DATA= `nc -l -p $PORT`
MD5_CHECK=`md5sum $FILE | cut -d " " -f 1`
DATA_NAME=`echo $DATA | cut -d " " -f 2`
DATA_MD5=`echo $DATA | cut -d " " -f 3`

if [ "$MD5_CHECK" != "$DATA_MD5" ]; then
	sleep 1
	echo "Server MD5 : $MD5_CHECK"
	echo "Client MD5 : $DATA_MD5"
	sleep 1
	echo "DATA STATUS: Corrupto"
	echo "KO_DATA" | nc -q 1 $IP_CLIENT $PORT
	echo "Connection status: Failed " | mail -s "ABFP_Admin" alejandor_test@mailinator.com
	exit 4
fi
sleep 1
echo "(16) FILE_STATUS Response"
echo "OK_DATA" | nc -q 1 $IP_CLIENT $PORT
echo "File Status: OK ! $MD5_CHECK / $DATA_MD5" | mail -s 'ABFP-Admin' alejandro_test@mailinator.com
exit 0


























