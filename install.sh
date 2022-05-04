#!/bin/bash
#set -x #echo on

## Run system Updates
function sys_update() {
  echo 'Lets make sure your system is updated, shall we?...'
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
  echo 'Installing OctoPrint in virtual environment...'
  pip install octoprint
  echo 'Installing OctoPrint auto-start scripts...'
  wget https://github.com/OctoPrint/OctoPrint/raw/master/scripts/octoprint.service && sudo mv octoprint.service /etc/systemd/system/octoprint.service
  sudo systemctl enable octoprint.service
  echo 'OctoPrint services installed!...'
}

function webcam_support() {
  cd ~
  echo 'Installing mjpg-streamer...'
  sudo apt install subversion libjpeg62-turbo-dev imagemagick ffmpeg libv4l-dev cmake
  git clone https://github.com/jacksonliam/mjpg-streamer.git
  cd mjpg-streamer/mjpg-streamer-experimental
  export LD_LIBRARY_PATH=.
  make
  cd ~
  mkdir scripts && cd scripts
# TODO enable reading in of resolution and updating webcam daemon script
# read -p "Would resolution is your webcam? [1920x1080]" -i Y resolution
# read -p "Would is the frame rate of your webcam? [30]" -i Y frame_rate
  echo 'Install webcam auto-start scripts...'
  wget https://raw.githubusercontent.com/hobie2987/octoprint-orange-pi4-lts/main/scripts/webcamd && sudo mv webcamd /home/pi/scripts/webcamd
  echo 'Updating script permissions...'
  chmod +x /home/pi/scripts/webcamd
  echo 'Install webcam services...'
  wget https://raw.githubusercontent.com/hobie2987/octoprint-orange-pi4-lts/main/services/webcamd.service && sudo mv webcamd.service /etc/systemd/system/webcamd.service
  sudo systemctl enable webcamd.service
  echo 'Webcam services installed!...'
}

function set_permissions() {
  sudo su root
  read -n 1 -p "Would you like to disable password for user pi? [y,n]: " -i Y nopass
  if [ "$nopass" == "y" ]; then
    echo 'pi ALL=(ALL) NOPASSWD:ALL' | sudo tee -a /etc/sudoers
  else
    echo 'pi ALL=NOPASSWD: /sbin/shutdown' | sudo tee -a /etc/sudoers.d/octoprint-shutdown
    echo 'pi ALL=NOPASSWD: /usr/sbin/service' | sudo tee -a /etc/sudoers.d/octoprint-service
  fi
}

function fin() {
  echo 'OctoPrint is now installed with webcam support!  Please reboot your Orange Pi!'
  exit 0
}

sys_update
pi_user
install_octoprint
webcam_support
set_permissions
fin