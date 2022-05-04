#!/bin/bash
#set -x #echo on

## Run system Updates
function sys_update() {
  sudo apt-get update
  sudo apt-get upgrade
}

function pi_user() {
  echo 'Creating sudo user: pi...'
  sudo adduser pi

  if ! id -u 'pi' >/dev/null 2>&1; then
    echo 'User pi failed to be created...'
    exit -1
  else
    echo 'Granting pi user sudo permissions...'
    sudo usermod -aG sudo pi
    sudo usermod -a -G tty pi
    sudo usermod -a -G dialout pi
    read -n 1 -p "Would you like to disable password for user pi? [y,n]: " -i Y nopass
    if [ "$nopass" == "y" ]; then
      echo 'pi ALL=(ALL) NOPASSWD:ALL' | sudo tee -a /etc/sudoers
    fi
  fi
}

function install_octoprint() {
  echo 'Installing Python virtual environment...'
  python3 --version
  sudo apt update
  sudo apt install python3-pip python3-dev python3-setuptools python3-venv git libyaml-dev build-essential
  cd ~
  mkdir OctoPrint && cd OctoPrint
  python3 -m venv venv
  source venv/bin/activate
  pip install pip --upgrade
  echo 'Installing Octoprint in virtual environment!...'
  pip install octoprint
  echo 'Installing OctoPrint auto-start scripts...'
  wget https://github.com/OctoPrint/OctoPrint/raw/master/scripts/octoprint.service && sudo mv octoprint.service /etc/systemd/system/octoprint.service
  sudo systemctl enable octoprint.service
  echo 'OctoPrint services installed!...'
}
#
function webcam_support() {
 cd ~
 sudo apt install subversion libjpeg62-turbo-dev imagemagick ffmpeg libv4l-dev cmake
 git clone https://github.com/jacksonliam/mjpg-streamer.git
 cd mjpg-streamer/mjpg-streamer-experimental
 export LD_LIBRARY_PATH=.
 make
 cd ~
 mkdir scripts
 read -p "Would resolution is your webcam? [1920x1080]" -i Y resolution
 read -p "Would is the frame rate of your webcam? [30]" -i Y frame_rate
 # download file from github, and modify string?
 # assume project is cloned, move file and modify?

 chmod +x /home/pi/scripts/webcamd
 wget https://github.com/OctoPrint/OctoPrint/raw/master/scripts/octoprint.service && sudo mv octoprint.service /etc/systemd/system/octoprint.service
 #sudo nano /etc/systemd/system/webcamd.service
 # download file and to respective directory
}

sys_update
pi_user
#install_octoprint
#webcam_support
#echo OctoPrint is now installed!  Please reboot your Orange Pi!
#
#exit 0
