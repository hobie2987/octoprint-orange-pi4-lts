# octoprint-orange-pi4-lts
Octoprint Install for Orange Pi 4 LTS

I am working on a script to make this more streamlined, but for now, here are the steps with the manual commands

# Update system
$ sudo apt-get update\
$ sudo apt-get upgrade

# Create "pi" sudo user
$ sudo adduser pi\
$ sudo usermod -aG sudo pi\
$ sudo usermod -a -G tty pi\
$ sudo usermod -a -G dialout pi

To disable the password requirement for pi user, do the following:

$ sudo visudo
- Paste at end of file:
  - pi ALL=(ALL) NOPASSWD:ALL
  - Ctrl+x
  - (Y)es
  - Enter

# Install Python + PIP Dependencies
$ python3 --version\
$ sudo apt update\
$ sudo apt install python3-pip python3-dev python3-setuptools python3-venv git libyaml-dev build-essential

# Create virtual environment and install Octoprint
$ cd ~\
$ mkdir OctoPrint\
$ cd OctoPrint\
$ python3 -m venv venv\
$ source venv/bin/activate\
$ pip install pip --upgrade\
$ pip install octoprint

# Auto-start Octoprint
$ wget https://github.com/OctoPrint/OctoPrint/raw/master/scripts/octoprint.service && sudo mv octoprint.service /etc/systemd/system/octoprint.service\
$ sudo systemctl enable octoprint.service

# Webcam Support
$ sudo apt install subversion libjpeg62-turbo-dev imagemagick ffmpeg libv4l-dev cmake\
$ git clone https://github.com/jacksonliam/mjpg-streamer.git \
$ cd mjpg-streamer/mjpg-streamer-experimental\
$ export LD_LIBRARY_PATH=.\
$ make\
$ cd ~\
$ mkdir scripts && cd scripts\
$ sudo nano webcamd
- Paste contents of scripts/webcamd
- Update "camera_usb_options" with the desired resolution and frames settings
  - Default setting is "-r 1920x1080 -f 30"
- Ctrl+x
- (Y)es to confirm save
- Enter

$ chmod +x /home/pi/scripts/webcamd\
$ sudo nano /etc/systemd/system/webcamd.service
- Paste contents of services/webcamd.service
- Ctrl+x
- (Y)es to confirm save
- Enter

# Enable system restart/shutdown from Octoprint
These steps are only required if you did not disable password requirements for pi user

$ sudo su root
$ sudo nano /etc/sudoers.d/octoprint-shutdown
- Paste in file:
    - pi ALL=NOPASSWD: /sbin/shutdown
  
$sudo nano /etc/sudoers.d/octoprint-service
- Paste in file:
  - pi ALL=NOPASSWD: /usr/sbin/service


# Ocotprint Shutdown/Restart commands

- Restart Octoprint
  - $ sudo service octoprint restart
  
- Restart system:
  - $ sudo shutdown -r now
  
- Shutdown system:
  - $ sudo shutdown -h now

