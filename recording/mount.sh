#!/bin/bash
USERNAME=
SMB_USER=
SMB_PW=
SERVER=gob-store
SMB_share=guest

sudo mount -t cifs -o user=$SMB_USER,password=$SMB_PW,dir_mode=0777,file_mode=0777 //${gob-store}/${SMB_share} /mnt/hdd
sudo chown $USERNAME:$USERNAME /mnt/hdd
echo "Test touch..."
touch /mnt/hdd/$HOSTNAME
rm /mnt/hdd/$HOSTNAME

