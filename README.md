#This is the repository for the Goblotrop-System
#This system was used to analyse the circadian rythm of mice
#In order to replicate the results,
#this system is open-source.
#
#Due to my time restrictions, the system does not have a nice GUI and is not  a self-runner 
#Operating the system needs an understanding of the underlying concepts and linux.
#Atleast a master-student in EE or CS should have the understanding to operate the system


The basic concept of the system is explained by: ...eNeuroPaper...
This repository consists of the following dirs:

3dMaterial: 
	- scad and STL files to rebuild the cage mountings 

recording:
	- scripts and stuff which are run on the Raspberry Pis
	- the scripts work together with the scripts used in orchestration

orchestration:
	- scripts to control the raspberry pis via one host computer
	- the files are shared via smb to a hosted mount
	- the videos are started via cron-job



