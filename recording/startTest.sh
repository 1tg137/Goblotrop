#!/bin/bash

myDate=$(date +%d-%m-%Y)
VIDPATH=/mnt/hdd/vid/${myDate}
mkdir -p ${VIDPATH}
raspivid -t 10 -w 1640 -h 1232 -fps 25 -o $VIDPATH/$HOSTNAME.h264 -pts $VIDPATH/$HOSTNAME.txt
#raspivid -t 0 -w 3280 -h 2464 -fps 10 -o /mnt/hdd/vids/$HOSTNAME/test.h264
