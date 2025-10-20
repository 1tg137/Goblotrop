#!/bin/bash

path="/mnt/hdd/shot/"
errpath="/mnt/hdd/err/"
libcamera-jpeg --width 1640 --height 1232 -o ${path}$HOSTNAME.jpg > ${errpath}/$HOSTNAME.err 


