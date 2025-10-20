import socket
import os
import datetime


scriptPath="/home/gob/goblotrop-mcam/"
port = 65002
myName=socket.gethostname()
mynumber=int(myName[4])
port+=(mynumber*2)
if myName[5] == 's':
  port+=1

print(port, type(port))

client = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP) # UDP
client.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEPORT, 1)
client.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
client.bind(("", port ))
#ret = client.bind(("", 44020 ))
vidPath="/mnt/hdd/vids/"
testPath="/mnt/hdd/test/"
os.system("mkdir -p /mnt/hdd/log/")
os.system("mkdir -p /mnt/hdd/vids/")
os.system("mkdir -p /mnt/hdd/test/")
myName=socket.gethostname()

log="/mnt/hdd/log/"+myName+".txt"
flag=0
server =0 
while True:
        print("Waiting for message")
        data, addr = client.recvfrom(1024)
        data=data.decode()
        print("received message:>",data,"<")

        f=open(log,'a+')
        x=str(datetime.datetime.now())
        f.write(x+" "+data+" pid: \n")
        f.close()
    #    print(x)
        if data=="start":
           os.system(scriptPath+"startTest.sh") 
           flag=1
     #      f.write(x+" "+data+"\n")
           
        if data=="shot":
           ret =os.system(scriptPath+"takeShot.sh")
           ret = str( 1 )
 #           print("return:",ret)
           sent = client.sendto( ret.encode(), addr );
#            print( str(ret), addr ) 
           print( sent )
           flag=1
      #     f.write(x+" "+data+"\n")

        if data=="test":
           command="touch "+testPath+myName+".tst"
           os.system(command)
           flag=1
        #   print(command)
       #    f.write(x+" "+data+"\n")

        if data=="getDate":
            os.system("timedatectl")
            flag=1
        #    f.write(x+" "+data+"\n")

        if data=="mount":
            os.system(scriptPath+"mount.sh")
            flag=1
        #    f.write(x+" "+data+"\n")

        if data=="kill":
            print(" Got it! ")
            ret =os.system("pkill -SIGINT libcamera-vid")
            print( ret )
            flag=1
         #   f.write(x+" "+data+"\n")

        if data=="startCam":
            os.system(scriptPath+"startCam.sh &")
            flag=1
          #  f.write(x+" "+data+"\n")

        if data=="check_cam":
         #  f.write(x+" "+data+" pid: ")
            ret = os.system("pgrep libcamera-vid >> "+log) 
            ret = str( ret )
 #           print("return:",ret)
            sent = client.sendto( ret.encode(), addr );
#            print( str(ret), addr ) 
            flag=1
           
