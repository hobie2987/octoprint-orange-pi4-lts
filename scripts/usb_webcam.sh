#!/bin/bash

# Returns the devname of the device that meets the following criteria
# ID_BUS=usb, ID_TYPE=video, ID_V4L_CAPABILITIES=:capture:
# Usage:  webcam.identify
# Returns: /dev/video0
function webcam.identify() {
  devices=$(v4l2-ctl --list-devices | grep -o "/dev/video[0-9]")
  devices=($devices)
  for d in "${devices[@]}"; do
    bus=$(udevadm info --query=property --name="$d" | grep "ID_BUS=*" | cut -d = -f 2)
    type=$(udevadm info --query=property --name="$d" | grep "ID_TYPE=*" | cut -d = -f 2)
    caps=$(udevadm info --query=property --name="$d" | grep "ID_V4L_CAPABILITIES=*" | cut -d = -f 2)
    #echo "DEV=$d  BUS=$bus TYPE=$type CAPS=$caps"
    if [ "$bus" == "usb" ] && [ "$type" == "video" ] && [[ "$caps" == *":capture:"* ]]; then
     echo "$d"
     break;
    fi
  done
}


# Returns the model name of the request device
# Usage: model /dev/video0
# Returns: NexiGo_N930E_FHD_Webcam
function webcam.model() {
  #udevadm info -q property -n /dev/video5
  udevadm info --query=property --name="$1" | grep "ID_MODEL=" | cut -d = -f 2
}

# Returns all supported resolutions for the provided device
# Usage: webcam.resolution /dev/video0
# Returns: 640x480
#          320x240
#          800x600
#          1280x720
#          1280x960
#          1920x1080
function webcam.resolutions() {
  v4l2-ctl -d "$1" --list-framesizes=MJPG | grep -o "[0-9]*x[0-9]*"
  #| tail -1 => returns last
}

# Returns all framerate of the request device and resolutions
# Usage: webcam.fps /dev/video0 1920x1080
# Returns: 30.000
#          25.000
#          20.000
function webcam.fps() {
  readarray -d x -t strarr <<< "$2"
  v4l2-ctl -d "$1" --list-frameintervals=width="${strarr[0]}",height="${strarr[1]}",pixelformat=MJPG | egrep -o "[[:digit:]]{2,}.[[:digit:]]{3,}"
  # | egrep -o -E -m 1 "[[:digit:]]{2}" | head -1
}

# Prints info for proviced webcam device
# Usage: webcam.info /dev/video0
function webcam.info() {
  MAX_RES=$(webcam.resolutions "$1" | tail -1)
  MAX_FPS=$(webcam.fps "$1" "$MAX_RES" | head -1)
  echo "**************************************"
  echo "*       Detected USB webcam          *"
  echo "**************************************"
  echo "Device Model: $(webcam.model $1)"
  echo "Device Name: $1"
  echo "Max Resolution: $MAX_RES"
  echo "Max Frame Rate (FPS): $MAX_FPS"
  echo "**************************************"
}