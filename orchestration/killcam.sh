#!/bin/bash

#command="startCam"
command="kill"
for cnt in {1..4}
do
 for fs in f s
 do
   if [ $fs == 'f' ]
   then
    let "port= 65002 + cnt*2"
  else
    let "port= 65002 + cnt*2 + 1"
  fi

#   echo gobCam${cnt}${fs}  $port
   echo -n $command | nc -u gobCam${cnt}${fs} ${port}
   echo  $command to gobCam${cnt}${fs} ${port}

 done
done 
