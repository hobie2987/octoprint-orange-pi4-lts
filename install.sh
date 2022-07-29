#!/bin/bash
#set -x #echo on

hostname=$(hostname -I | cut -d" " -f1)

# Green text
function INFO() {
  echo -e "\e[1;35m$1\e[1;m"
#  echo $1
}

# Yellow text
function WARN() {
  echo -e "\e[1;33m$1\e[1;m"
  #  echo $1
}

# Run system Updates/Upgrades
function sys_update() {
  INFO 'Lets make sure your system is updated, shall we?...'
  sudo apt-get update
  sudo apt-get upgrade
}

# Creates user "pi",
# Assign pi user to sudo group
function pi_user() {
  if ! id -u 'pi' >/dev/null 2>&1; then
    INFO 'Creating sudo user: pi...'
    sudo adduser pi
    INFO 'Granting pi user sudo permissions...'
    sudo usermod -aG sudo pi
  else
    WARN 'pi user exists, but permissions will be updated'
  fi

  INFO 'Granting pi user serial port access...'
  sudo usermod -a -G tty pi
  sudo usermod -a -G dialout pi
}

# Download Python dependencies
# Make OctoPrint install directory
# Generate VM for OctoPrint, and install
# Download Octoprint auto-start services
function install_octoprint() {
  INFO 'Installing Python virtual environment...'
  python3 --version # Prints Python version
  sudo apt update
  sudo apt install python3-pip python3-dev python3-setuptools python3-venv git libyaml-dev build-essential
  cd /home/pi
  mkdir -v OctoPrint
  cd OctoPrint
  pwd
  python3 -m venv venv
  source venv/bin/activate
  pip install pip --upgrade
  INFO 'Installing OctoPrint in virtual environment...'
  pip install octoprint
  INFO 'Installing OctoPrint auto-start scripts...'
  wget https://github.com/OctoPrint/OctoPrint/raw/master/scripts/octoprint.service && sudo mv octoprint.service /etc/systemd/system/octoprint.service
  cd /home/pi
  sudo chown -R pi OctoPrint
  INFO 'OctoPrint services installed!...'
}

# Install MJPG dependencies
# Clone Git repo
# Download Webcam Daemon script, and add execute permissions
# Provide video access to pi user
# Download webcam services
function webcam_support() {
  cd /home/pi
  INFO 'Installing mjpg-streamer...'
  sudo apt install subversion libjpeg62-turbo-dev imagemagick ffmpeg libv4l-dev cmake
  git clone https://github.com/jacksonliam/mjpg-streamer.git
  cd mjpg-streamer/mjpg-streamer-experimental
  export LD_LIBRARY_PATH=.
  sudo make
  cd /home/pi
  mkdir -v scripts
  cd scripts
  pwd
# TODO enable reading in of resolution and updating webcam daemon script
# read -p "Would resolution is your webcam? [1920x1080]" -i Y resolution
# read -p "Would is the frame rate of your webcam? [30]" -i Y frame_rate
  INFO 'Installing webcam auto-start scripts...'
  wget https://raw.githubusercontent.com/hobie2987/octoprint-orange-pi4-lts/main/scripts/webcamd
  INFO 'Updating script permissions...'
  sudo chmod +x /home/pi/scripts/webcamd
  sudo chmod 666 /dev/video0
  INFO 'Install webcam services...'
  wget https://raw.githubusercontent.com/hobie2987/octoprint-orange-pi4-lts/main/services/webcamd.service && sudo mv webcamd.service /etc/systemd/system/webcamd.service
  INFO 'Webcam services installed!...'
}

# Remove sudo password requirements for user pi
function set_permissions() {
  INFO 'Lets set some permissions for user pi...'
#    echo 'pi ALL=(ALL) NOPASSWD:ALL' | sudo tee -a /etc/sudoers
#    echo 'pi ALL=NOPASSWD: /sbin/shutdown' | sudo tee -a /etc/sudoers.d/octoprint-shutdown
#    echo 'pi ALL=NOPASSWD: /usr/sbin/service' | sudo tee -a /etc/sudoers.d/octoprint-service
  sudo tee -a /etc/sudoers > /dev/null <<EOT

pi ALL=(ALL) NOPASSWD:ALL
EOT

  sudo tee -a /etc/sudoers.d/octoprint-shutdown > /dev/null <<EOT

pi ALL=NOPASSWD: /sbin/shutdown
EOT

  sudo tee -a /etc/sudoers.d/octoprint-service > /dev/null <<EOT

pi ALL=NOPASSWD: /usr/sbin/service
EOT
}

function reverse_proxy() {
  sudo apt install haproxy
  sudo tee -a /etc/haproxy/haproxy.cfg > /dev/null <<EOT

frontend public
        bind :::80 v4v6
        use_backend webcam if { path_beg /webcam/ }
        default_backend octoprint

backend octoprint
        option forwardfor
        server octoprint1 127.0.0.1:5000

backend webcam
        http-request replace-path /webcam/(.*)   /\1
        server webcam1  127.0.0.1:8080
EOT
}

# Reload Daemon
# Enable OctoPrint, Webcam services
# Start Reverse Proxy, OctoPrint, and Webcam services
function start_services() {
  sudo systemctl daemon-reload
  sudo systemctl enable octoprint.service
  sudo systemctl enable webcamd.service
  sudo service haproxy start
  sudo systemctl start octoprint
  sudo systemctl start webcamd
}

# Output URLs for OctoPrint and Webcam stream
function fin() {
  INFO 'OctoPrint is now installed with webcam support!  Please reboot your system!'
  INFO '-------------------------------------------------------------------------------'
  INFO 'OctoPrint is running @: http://'${hostname}/
  INFO 'Webcam stream is running @: http://'${hostname}/webcam/?action=stream
  INFO '-------------------------------------------------------------------------------'
  INFO 'System commands'
  INFO 'Restart OctoPrint: sudo service octoprint restart'
  INFO 'Restart System: sudo shutdown -r now'
  INFO 'Shutdown System: sudo shutdown -h now'
  INFO '-------------------------------------------------------------------------------'
  INFO 'Webcam & Timelapse Settings'
  INFO 'Stream URL: /webcam/?action=stream'
  INFO 'Snapshot URL: http://127.0.0.1:8080/?action=snapshot'
  INFO 'Path to FFMPEG: /usr/bin/ffmpeg'
  INFO '-------------------------------------------------------------------------------'
  # serverRestartCommand - sudo service octoprint restart
  # systemRestartCommand - sudo shutdown -r now
  # systemShutdownCommand - sudo shutdown -h now
}

sys_update
pi_user
install_octoprint
webcam_support
set_permissions
reverse_proxy
start_services
fin
exit 0