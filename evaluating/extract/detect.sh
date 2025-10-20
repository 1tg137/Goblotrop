#!/bin/bash

if [ $# -ne 2 ]
then
	echo "Usage: ./run.sh "front/side" video_file.mp4"
	echo "You need to append the video file"
	exit
fi

if [[ "$1" != "front" && "$1" != "side" ]]
then
	echo "Usage: ./run.sh "front/side" video_file.mp4"
	echo "You used ./run.sh $1" 
	exit
fi 


vidfile=$2
bname=$(basename $2)
bname=${bname%.*}

if [ "$1" = "front" ]
then
				weights=yolov4_front.weights
				cfg=yolov4_front.cfg
				result=results_f/$bname.json
fi	
if [ "$1" = "side" ]
then
				weights=yolov4_side.weights
				cfg=yolov4_side.cfg
				result=results_s/$bname.json
fi	
./darknet detector demo data/obj.data $cfg $weights -ext_output -json_file_output $result -dont_show  $vidfile 

