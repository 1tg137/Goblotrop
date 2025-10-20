import json
import sys
import os


def json2yolo( file_json ):
  try:
    aFile = open(file_json)
    l_frames = json.load(aFile)
  except:
    print("Error on loading:", file_json )
    return 0 
  aFile.close()

  yolo_l = []
  for k in range(len(l_frames)):
    string=""
    frame = l_frames[k]
  #  print(k, end=", ")
    string+=str(k)+", "
    for obj in frame['objects']:
      class_id = obj['class_id']
      conf = obj['confidence']
      coords=obj['relative_coordinates']
      center_x = coords['center_x']
      center_y = coords['center_y']
      width = coords['width']
      height = coords['height']
   #   print(class_id, conf, center_x, center_y, width, height, end=" ")
      string+=str(class_id)+" "
      string+=str(conf) +" "
      string+=str(center_x)+" "
      string+=str(center_y)+" "
      string+=str(width)+" "
      string+=str(height)+" "
    yolo_l.append(string)
  
  print("json2yolo done")
  return yolo_l


#    string+="\n"
#    file_txt.write(string)
    
#      print(obj)
#    for coord in frame['coord']

#print(sys.argv)
#basename = os.path.splitext( sys.argv[1] )[0]
#print(basename)
#two_files = ( sys.argv[1] , basename+".txt" ) 
#json2python( two_files )



