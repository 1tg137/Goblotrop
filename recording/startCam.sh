#!/bin/bash

myDate=$(date +%d-%m-%Y)
VIDPATH="/mnt/hdd/vid/${myDate}"
mkdir -p $VIDPATH
libcamera-vid -t 0 --width 1640 --height 1232 --framerate 15 --codec h264 -o ${VIDPATH}/${HOSTNAME}.h264 --save-pts ${VIDPATH}/${HOSTNAME}.txt & 
