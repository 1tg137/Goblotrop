import torch
import sys
sys.path.append("/home/tg245/git/vecnet/modules/")
sys.path.append("/home/tg245/git/vecnet/net/")
import torch.nn as nn
import torch.nn.functional as F
from decimal import Decimal
from os.path import exists
import time
import torch.optim as optim
import datetime
import random
import torchvision
import math
from net import *
from getTrainingData import *
import argparse
from torch.multiprocessing import set_start_method, Queue
import torch.multiprocessing as mp
import string
import torch.optim.lr_scheduler as lr_scheduler
from dataloader import *
from parseme import *
import numpy as np
from json2yolo import *

## 0 wheel
## 1 house
## 2 mouse
##

def lineToTenWrapper(list_of_lines):
    ten_list=[]
    for k in range(len(list_of_lines)):
        ten_list.append( lineToTen(list_of_lines[k]).unsqueeze(dim=0) )

    ten = torch.cat(ten_list)
    return ten

def checkInAreaWheelWrapper(ten_data):
    ten_wheel = torch.zeros(ten_data.size(dim=0))
    for k in range(ten_data.size(dim=0)):
        ten_wheel[k] = checkInArea(ten_data[k,2],ten_data[k,0])

    return ten_wheel #, ten_house

def checkInAreaHouseWrapper(ten_data):
    ten_house = torch.zeros(ten_data.size(dim=0))
    for k in range(ten_data.size(dim=0)):
        ten_house[k] = checkInArea(ten_data[k,2],ten_data[k,1])
    return ten_house

def checkIfMissWrapper(ten_data):
    ten_miss = torch.zeros(ten_data.size(dim=0))
    for k in range(ten_data.size(dim=0)):
        ten_miss[k] = checkIfMiss(ten_data[k,2])
    return ten_miss 

def checkIfMissWrapper_house(ten_data):
    ten_miss = torch.zeros(ten_data.size(dim=0))
    for k in range(ten_data.size(dim=0)):
        ten_miss[k] = checkIfMiss(ten_data[k,1])
    return ten_miss 

#TODO check if miss differs now
def checkIfMiss(ten_data):
    if ten_data.sum() == 0:
      return 1
    else:
      return 0

def checkMovementInFileWrapper( ten_data ):
  ten_movement = torch.zeros( ten_data.size(dim=0),2 )
  for k in range(1,ten_data.size(dim=0)):
      aTuple = checkMovementInFile(ten_data[k-1,2], ten_data[k,2])
      ten_movement[k,0] = aTuple[0]
      ten_movement[k,1] = aTuple[1]
  return ten_movement

def checkMovementInFile(ten_data_prev, ten_data):
    #TODO
    if checkIfMiss( ten_data_prev) or checkIfMiss(ten_data) :
        return (0,0)
    dx = math.fabs(ten_data_prev[0] - ten_data[0])
    dy = math.fabs(ten_data_prev[1] - ten_data[1])
    return (dx, dy)

def lineToTen( line ):
    if not line:
        print("Error! No line! ")
    nr_classes = 3
    line.replace('–','-')
#    line = line.replace('.',',')
#    print(line)
    line = line.split(' ')
    ten = torch.zeros( (nr_classes,4), dtype=torch.float )
    for q in range(nr_classes):
        lineaddon = 1+q*6
        if len( line ) > (lineaddon+6):
            try:
              class_nr = int(line[lineaddon])
            except:
              class_nr = -1
              print("ERROR ERROR ERROR: line,lineaddon  ,line[lineaddon]" )
#              return ten

            if class_nr >= 0:
              prob = line[lineaddon+1]
              if float(prob) > 0.5:
                  x = line[lineaddon+2]
                  y = line[lineaddon+3]
                  w = line[lineaddon+4]
                  h = line[lineaddon+5]
#                print(type(line[lineaddon+2]))
                  ten[class_nr][0] = float(x) #float(line[lineaddon+2])
                  ten[class_nr][1] = float(y) #float(line[lineaddon+3])
                  ten[class_nr][2] = float(w) #float(line[lineaddon+4])
                  ten[class_nr][3] = float(h) #float(line[lineaddon+5])

#    print(class_nr, prob, x,y,w,h)
#    return nr_frame, ten
#    print("I am done!")
    return ten

def checkInArea(ten_mouse, ten_area):
    area_x = ten_area[0]  
    area_y = ten_area[1]
    area_w = ten_area[2]
    area_h = ten_area[3]
    what = 0
    if ten_mouse[0] < (area_x + area_w/2) and ten_mouse[0] > (area_x - area_w/2) and ten_mouse[1] < (area_y + area_h/2) and  ten_mouse[1] > (area_y - area_h/2):
        what=1

    return what

def checkHouse_special( front_data, side_data ):
  ten_house = torch.zeros( front_data.size(dim=0))
  for k in range( front_data.size(dim=0)):
    if checkInArea( side_data[k,2], side_data[k,1]) and checkInArea( front_data[k,2], side_data[k,1] ):
      ten_house[k] = 1
    if checkInArea(side_data[k,2],side_data[k,1]) and checkIfMiss( front_data[k,2] ):
      ten_house[k] = 1

  return ten_house
  

def evaluate_wrapper( aTuple ):
        return evaluate( aTuple[0], aTuple[1], aTuple[2], aTuple[3] )

def checkMovementTwoFiles( front_movement, side_movement, ten_wheel ): 
  ten_movement = torch.zeros( front_movement.size(dim=0))
  for k in range( front_movement.size(dim=0)):
    if ten_wheel[k] == 0:
      dz = ( front_movement[k,1] + side_movement[k,1] )/2
      dx = front_movement[k,0]
      dy = side_movement[k,0]
      ten_movement[k] = math.sqrt( pow(dx,2) + pow(dy,2) + pow(dz,2 ) )
  return ten_movement

def evaluate( filepath_front, filepath_side, framerate, outfile ):
#    print("filepath_front:",filepath_front)
    if not (os.path.exists( filepath_front ) and os.path.exists(filepath_side)):
#      print("One of the files dont exists. Exit"  )
      return 
    front_lines = json2yolo( filepath_front )
    front_ten, front_wheel, front_house, front_miss,front_miss_house, front_move = evaluate_file( front_lines )
    side_lines = json2yolo( filepath_side )
    side_ten, side_wheel, side_house, side_miss, side_miss_house, side_move = evaluate_file( side_lines )
    
    size_front_house = front_house.size(dim=0)
    size_side_house = side_house.size(dim=0)
    if size_front_house < size_side_house:
        size = size_front_house
    else:
        size = size_side_house

    front_ten = front_ten[0:size]
    side_ten = side_ten[0:size]
    ten_house = torch.multiply(front_house[0:size],side_house[0:size] )
#    ten_house = checkHouse_special(front_ten , side_ten)
    ten_house_side = side_house[0:size] # torch.multiply(front_house[0:size],side_house[0:size] )
    ten_house_front = front_house[0:size] # torch.multiply(front_house[0:size],side_house[0:size] )
    ten_wheel = torch.multiply(front_wheel[0:size] ,side_wheel[0:size] )
    ten_miss_front = front_miss[0:size] #torch.add(front_miss[0:size] ,side_miss[0:size] )
    ten_miss_side = side_miss[0:size] #torch.add(front_miss[0:size] ,side_miss[0:size] )
    ten_miss_house_front = front_miss_house[0:size] #torch.add(front_miss[0:size] ,side_miss[0:size] )
    ten_miss_house_side = side_miss_house[0:size] #torch.add(front_miss[0:size] ,side_miss[0:size] )
    ten_move  = checkMovementTwoFiles(front_move[0:size], side_move[0:size], ten_wheel )

#    print("Both in house:",ten_house.sum())
#    print("Both in wheel:", ten_wheel.sum())
#    print("Movement:", ten_move.sum())
#    print("One is missing:", ten_miss.sum(), "size:", ten_miss.size())
     
    # summarize hourly
    chunksize=framerate*3600
#    print("chunksize:",chunksize)
    chunks= int(front_house.size(dim=0)/(chunksize))
#    print("chunks:",chunks)
    ten_wheel_hours = torch.zeros((chunks+1,1)) # 22 ? 23 ?
    ten_house_hours = torch.zeros((chunks+1,1))
    ten_house_side_hours = torch.zeros((chunks+1,1))
    ten_house_front_hours = torch.zeros((chunks+1,1))
    ten_miss_front_hours= torch.zeros((chunks+1,1))
    ten_miss_side_hours = torch.zeros((chunks+1,1))
    ten_miss_house_front_hours= torch.zeros((chunks+1,1))
    ten_miss_house_side_hours = torch.zeros((chunks+1,1))
    ten_move_hours= torch.zeros((chunks+1,1))

    for k in range(chunks):
        ten_wheel_hours[k] = ten_wheel[k*chunksize: (k+1)*chunksize].sum()
        ten_house_hours[k] = ten_house[k*chunksize: (k+1)*chunksize].sum()
        ten_house_side_hours[k] = ten_house_side[k*chunksize: (k+1)*chunksize].sum()
        ten_house_front_hours[k] = ten_house_front[k*chunksize: (k+1)*chunksize].sum()
        ten_miss_front_hours[k] = ten_miss[k*chunksize: (k+1)*chunksize].sum()
        ten_miss_side_hours[k] = ten_miss[k*chunksize: (k+1)*chunksize].sum()
        ten_miss_house_front_hours[k] = ten_miss_house_front[k*chunksize: (k+1)*chunksize].sum()
        ten_miss_house_side_hours[k] = ten_miss_house_side[k*chunksize: (k+1)*chunksize].sum()
        ten_move_hours[k] = ten_move[k*chunksize: (k+1)*chunksize].sum()
#    print("Chunklala done")

    ten_wheel_hours[chunks] = ten_wheel[chunks*chunksize:-1].sum()/framerate
    ten_house_hours[chunks] = ten_house[chunks*chunksize:-1].sum()/framerate
    ten_house_side_hours[chunks] = ten_house_side[chunks*chunksize:-1].sum()/framerate
    ten_house_front_hours[chunks] = ten_house_front[chunks*chunksize:-1].sum()/framerate
    ten_miss_front_hours[chunks] = ten_miss_front[chunks*chunksize:-1].sum()/framerate
    ten_miss_side_hours[chunks] = ten_miss_side[chunks*chunksize:-1].sum()/framerate
    ten_miss_house_front_hours[chunks] = ten_miss_house_front[chunks*chunksize:-1].sum()/framerate
    ten_miss_house_side_hours[chunks] = ten_miss_house_side[chunks*chunksize:-1].sum()/framerate
    ten_move_hours[chunks] = ten_move[chunks*chunksize:-1].sum()/framerate

#    print("Writing now...")
    wheelfile = open(outfile+"-wheel.txt","w")
    for k in range(ten_wheel_hours.size(dim=0)):
#        print(k,ten_wheel_hours[k])
        wheelfile.write(str(ten_wheel_hours[k].item())+"\n")
    wheelfile.close()

    housefile = open(outfile+"-house.txt","w")
    for k in range(ten_house_hours.size(dim=0)):
#        print(k,ten_house_hours[k])
        housefile.write(str(ten_house_hours[k].item())+"\n")
    housefile.close()
    
    housefile = open(outfile+"-house_side.txt","w")
    for k in range(ten_house_side_hours.size(dim=0)):
#        print(k,ten_house_hours[k])
        housefile.write(str(ten_house_side_hours[k].item())+"\n")
    housefile.close()

    housefile = open(outfile+"-house_front.txt","w")
    for k in range(ten_house_front_hours.size(dim=0)):
#        print(k,ten_house_hours[k])
        housefile.write(str(ten_house_front_hours[k].item())+"\n")
    housefile.close()

    missfile = open(outfile+"-miss_front.txt","w")
    for k in range(ten_miss_front_hours.size(dim=0)):
#        print(k,ten_miss_hours[k])
        missfile.write(str(ten_miss_front_hours[k].item())+"\n")
    missfile.close()

    missfile = open(outfile+"-miss_side.txt","w")
    for k in range(ten_miss_side_hours.size(dim=0)):
#        print(k,ten_miss_hours[k])
        missfile.write(str(ten_miss_side_hours[k].item())+"\n")
    missfile.close()
    
    missfile = open(outfile+"-miss_house_front.txt","w")
    for k in range(ten_miss_house_front_hours.size(dim=0)):
#        print(k,ten_miss_hours[k])
        missfile.write(str(ten_miss_house_front_hours[k].item())+"\n")
    missfile.close()

    missfile = open(outfile+"-miss_house_side.txt","w")
    for k in range(ten_miss_house_front_hours.size(dim=0)):
#        print(k,ten_miss_hours[k])
        missfile.write(str(ten_miss_house_side_hours[k].item())+"\n")
    missfile.close()

    movefile = open(outfile+"-move.txt","w")
    for k in range(ten_move_hours.size(dim=0)):
#        print(k,ten_miss_hours[k])
        movefile.write(str(ten_move_hours[k].item())+"\n")
    movefile.close()

#    print("Writing Done")
    return

def low_pass_wrapper( list_ten ):
  list_lp = [] 
  return list_lp

def look_ahead( list_ten, what, k, how_far ):
    for q in range(k,k+how_far):
        if not checkIfMiss( list_ten[q][2] ):
          return q
    return 0

def fill_house_coords( list_ten ):
  list_all = []
  for k in range(0, list_ten.size(dim=0)):
      if not checkIfMiss( list_ten[k][1] ): 
          list_all.append( list_ten[k,1] )
#          print(list_all[-1])

  ten_house = torch.stack(list_all) 
  coord = torch.zeros(4)
  coord[0] = ten_house[:,0].sum() / ten_house.size(dim=0)
  coord[1] = ten_house[:,1].sum() / ten_house.size(dim=0)
  coord[2] = ten_house[:,2].sum() / ten_house.size(dim=0)
  coord[3] = ten_house[:,3].sum() / ten_house.size(dim=0)
  list_ten[:,1] = coord
  return list_ten
  
def fill_wheel_coords( list_ten ):
  list_all = []
  for k in range(0, list_ten.size(dim=0)):
      if not checkIfMiss( list_ten[k][0] ): 
          list_all.append( list_ten[k,0] )
#          print(list_all[-1])

  ten_house = torch.stack(list_all) 
  coord = torch.zeros(4)
  coord[0] = ten_house[:,0].sum() / ten_house.size(dim=0)
  coord[1] = ten_house[:,1].sum() / ten_house.size(dim=0)
  coord[2] = ten_house[:,2].sum() / ten_house.size(dim=0)
  coord[3] = ten_house[:,3].sum() / ten_house.size(dim=0)
  list_ten[:,0] = coord
  return list_ten

def low_pass( list_ten ):
  list_lp = torch.zeros( list_ten.size())
#  for k in range(1,list_ten.size(dim=0)):
  la = 100
  for k in range(1, list_ten.size(dim=0)-la):
      list_lp[k] = list_ten[k]
      if checkIfMiss( list_ten[k][2] ) and not checkIfMiss(list_ten[k-1][2]): 
        q = look_ahead( list_ten, 2, k , la )
        if q != 0:
          list_lp[k][2] = (list_ten[k-1][2] + list_ten[q][2])/2

  return list_lp


def evaluate_file( lines ): # file has to be read first
    # drei counter, house_time, wheel_time, outside_time
    house_cnt = 0
    wheel_cnt = 0
    frame_cnt = 0
    error_cnt = 0

    list_house = []
    list_wheel = []
    list_miss = []
    list_miss_house = []
    list_move=[]
    list_ten =lineToTenWrapper( lines )
    list_ten = low_pass(list_ten)
    list_ten = fill_house_coords(list_ten)
    list_ten = fill_wheel_coords(list_ten)
# here would be space to low pass...
    
    list_house.append( checkInAreaHouseWrapper(list_ten))
    list_wheel.append( checkInAreaWheelWrapper(list_ten))
    list_miss.append( checkIfMissWrapper(list_ten) )
    list_miss_house.append( checkIfMissWrapper_house(list_ten) )
    list_move.append( checkMovementInFileWrapper(list_ten) )

#    print("File done")
    
    ten_house = torch.cat(list_house)
    ten_wheel = torch.cat(list_wheel)
    ten_miss = torch.cat(list_miss)
    ten_miss_house = torch.cat(list_miss_house)
    ten_move = torch.cat(list_move)

#
#    print("#Frames:",frame_cnt)
#    print("house_cnt:",ten_house.sum(), ten_house.size())
#    print("wheel_cnt:",ten_wheel.sum(),ten_wheel.size())
#    print("miss_cnt:",ten_miss.sum(),ten_miss.size())
    return list_ten, ten_wheel, ten_house, ten_miss, ten_miss_house, ten_move
