#!/bin/bash
#set -x #echo on

HOSTNAME=$(hostname -I | cut -d" " -f1)
PI_HOME="/home/pi"
OCTOPRINT_DIR="$PI_HOME/OctoPrint"
MJPG_STREAMER_DIR="$PI_HOME/mjpg-streamer"
SCRIPTS_DIR="$PI_HOME/scripts"
WEBCAM_DAEMON="$SCRIPTS_DIR/webcamd"
TEMP_DIR="$PI_PI_HOME/tmp"

# Magenta text
function INFO() {
  echo -e "\e[1;35m$1\e[1;m"
}

# Yellow text
function WARN() {
  echo -e "\e[1;33m$1\e[1;m"
}

# Red text
function ERROR() {
  echo -e "\e[1;30m$1\e[1;m"
}

# Run system Updates/Upgrades
function sys_update() {
  INFO 'Lets make sure your system is updated, shall we?...'
  sudo apt update
  sudo apt upgrade
}

# Creates user "pi",
# Assign pi user to groups: sudo, video, tty, & dialout
# Creates directories /home/pi/[OctoPrint,scripts,mjpg-streamer,tmp]
function pi_user() {
  if ! id -u 'pi' >/dev/null 2>&1; then
    INFO 'Creating sudo user: pi...'
    sudo adduser pi
  else
    WARN 'User pi exists... updating user groups'
  fi

  INFO 'Adding pi to necessary groups [sudo, video, tty, dialout]...'
  sudo usermod -a -G sudo,video,tty,dialout pi

  INFO "Creating necessary directories..."
  mkdir -v -p "$OCTOPRINT_DIR" "$SCRIPTS_DIR" "$MJPG_STREAMER_DIR" "$TEMP_DIR"
}

# Installs required supporting packages
function install_packages() {
  INFO "Installing necessary packages..."
  INFO "Python version: $(python3 --version)"
  # Python3 + Virtual Environment Support
  # py_pkg="python3-pip python3-dev python3-setuptools python3-venv git libyaml-dev build-essential"
  # Webcam support
  # Removed - subversion
  # webcam_pkg="libjpeg-dev imagemagick ffmpeg libv4l-dev cmake v4l-utils"
  # Reverse Proxy support
  # proxy_pkg="haproxy"

  sudo apt install python3-pip python3-dev python3-setuptools python3-venv git libyaml-dev build-essential libjpeg-dev imagemagick ffmpeg libv4l-dev cmake v4l-utils haproxy
}

# Downloads service scripts and moves them to their appropriate destinations
function install_services() {
  INFO 'Installing Auto-Start Services...'
  cd "$TEMP_DIR"
  INFO 'Installing OctoPrint auto-start scripts...'
  wget https://github.com/OctoPrint/OctoPrint/raw/master/scripts/octoprint.service && sudo mv octoprint.service /etc/systemd/system/octoprint.service
  INFO 'Installing Webcam auto-start services...'
  wget https://raw.githubusercontent.com/hobie2987/octoprint-orange-pi4-lts/main/services/webcamd.service && sudo mv webcamd.service /etc/systemd/system/webcamd.service
  INFO 'Installing Webcam auto-start scripts...'
  wget https://raw.githubusercontent.com/hobie2987/octoprint-orange-pi4-lts/main/scripts/webcamd && sudo mv webcamd "$WEBCAM_DAEMON"
  sudo chmod +x "$WEBCAM_DAEMON"
}

# Generate VM for OctoPrint, and install
function install_octoprint() {
  INFO 'Installing OctoPrint in Python virtual environment...'
  cd "$OCTOPRINT_DIR"
  python3 -m venv venv
  source venv/bin/activate
  pip install pip --upgrade
  pip install octoprint
  sudo chown -R pi "$OCTOPRINT_DIR"
}

# Install MJPG dependencies
# Clone Git repo
function webcam_support() {
  INFO 'Installing mjpg-streamer...'
  git clone https://github.com/jacksonliam/mjpg-streamer.git "$MJPG_STREAMER_DIR"
  cd "$MJPG_STREAMER_DIR/mjpg-streamer-experimental"
  export LD_LIBRARY_PATH=.
  sudo make install
}

# Remove sudo password requirements for user pi
function set_permissions() {
  INFO 'Removing password requirement for user pi...'
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

# Configure OctoPrint to be be accessible on port 80
function reverse_proxy() {
  INFO 'Configuring reverse proxy...'
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
  INFO 'Refreshing/Restarting services...'
  sudo systemctl daemon-reload
  sudo systemctl enable octoprint.service
  sudo systemctl enable webcamd.service
  sudo service haproxy start
  sudo systemctl start octoprint
  sudo systemctl start webcamd
}

function cleanup() {
  rm -rf "$TEMP_DIR"
}

# Output URLs for OctoPrint and Webcam stream
function fin() {
  INFO 'OctoPrint is now installed with webcam support!  Please reboot your system!'
  INFO '-------------------------------------------------------------------------------'
  INFO 'OctoPrint is running @: http://'${HOSTNAME}/
  INFO 'Webcam stream is running @: http://'${HOSTNAME}/webcam/?action=stream
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

  WARN "Please reboot your device for these changes to take effect..."
  read -p "Press [R] to reboot, or any other key to exit: " -rsn1 input
    if [ "$input" = "r" ]; then
      WARN "Rebooting your device"
      sudo shutdown now -r
    else
      WARN "Exiting"
      exit 0
    fi
}

sys_update # Run System update/upgrade
install_packages # Install Supporting packages
pi_user # Create pi user, add user groups, and create required install directories
install_services # Download auto-start services and scripts
install_octoprint # Create virtual env and install OctoPrint
webcam_support # Clone MJPG streamer and set LD_LIBRARY_PATH
set_permissions # Remove sudo password requirement for user PI
reverse_proxy # Enable OctoPrint on port 80
start_services # Add and restart Daemons
cleanup # Delete temp directory
fin # Output OctoPrint/Webcam URLs/config, prompt reboot
