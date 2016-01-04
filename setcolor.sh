#!/bin/bash
#
# setcolor.sh <hue> <saturation> <brightness> <kelvin> <duration> [target]
#
# Marco Esposito M. <marco.esposito@gmail.com>
# Last update: 20150917
#

# frame
TAGGED=1
ADDRESSABLE=1
SOURCE=00000000
# frame address
TARGET=000000000000 # no little endian conversion 
ACK_REQUIRED=0 # [0,1]
RES_REQUIRED=0 # [0,1]
SEQUENCE=0 # [0,255]
# protocol header
TYPE=102 # [0,65535]

# payload
HUE=$1
SATURATION=$2
BRIGHTNESS=$3
KELVIN=$4
DURATION=$5

# target from command line
if [ ! -z $6 ]; then
	TAGGED=0
	TARGET=$6
fi  

# this is the final packet
PACKET=

# packdata <data>
function packdata() 
{
	local data=$1
    # little endian
	for (( i=${#data}-2; i>=0; i=i-2 )); do
		PACKET=${PACKET}${data:$i:2}
	done
}

# packdata_no <data> 
function packdata_no() 
{
	local data=$1
    # no little endian conversion
	PACKET=${PACKET}${data}
}


# bin2hex <number> 
function bin2hex() 
{
	local len=$(( ${#1}/4 ))
	printf "%0${len}X" $((2#$1))
}

# printpacket
function printpacket() 
{
	local size16=$((${#PACKET}/2+2))
	# little endian
	PACKET=$(printf '%02X%02X' ${size16:2:2} ${size16:0:2})${PACKET}
	for (( i=0; i<=${#PACKET}-2; i=i+2 )); do
		echo -n '\x'${PACKET:i:2}
	done
	echo
}

# the dirty work is here
packdata $(bin2hex 00${TAGGED}${ADDRESSABLE}010000000000) # 16 bits
packdata ${SOURCE} # source 32 
packdata_no ${TARGET}0000 # target 64
packdata_no 000000000000 # reserved 48
packdata $(bin2hex 000000${ACK_REQUIRED}${RES_REQUIRED}) # 8
packdata $(printf '%02X' ${SEQUENCE}) # sequence 8
packdata_no 0000000000000000 # reserved 64
packdata $(printf '%04X' ${TYPE}) # type 16
packdata_no 0000 # reserver 16

# payload 
packdata_no 00   # reserved 8
packdata $(printf '%04X' ${HUE}) # hue 16
packdata $(printf '%04X' ${SATURATION}) # saturation 16
packdata $(printf '%04X' ${BRIGHTNESS}) # brightness 16
packdata $(printf '%04X' ${KELVIN}) # kelvin 16
packdata $(printf '%08X' ${DURATION}) # duration 32

printpacket
