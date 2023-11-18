# OctoPrint Installer for Orange Pi (OPi) #

As we all know, Raspberry Pi's are hard to come by, and if you do find one, it comes with a ridiculous price tag.  I was
faced with this issue, so I sought out and alternate solution and purchased an Orange Pi 4 LTS board.  After purchasing,
I realized there was minimal support from the OctoPrint community, and saw this as an opportunity.  After many failed 
attempts of following the Linux install instructions, I finally learned there are gaps in the documentation.  Rather than 
documenting the process in depth so others do not make the same mistake, I instead scripted the installation process, 
and automation reduces the chances of making a mistake, causing you to restart the whole process over. 

## Tested and Verified Orange Pi models ##
- Orange Pi 4 LTS
  - 4 GB RAM + 16 GB EMMC Flash storage - https://www.aliexpress.us/item/3256804167807493.html
  - 3 GB RAM + Empty EMMC - https://www.aliexpress.us/item/3256804196540484.html
- Orange Pi  5b
  - 8 GB RAM + 64 GB EMMC Flash storage https://www.aliexpress.us/item/3256805170151035.html
- Orange Pi 3b 
  - 4GB RAM + Empty EMMC - https://www.aliexpress.us/item/3256805733558464.html

## Requirements ## 
- 32+ GB microSD card
  - I recommend Sandisk Extreme series (32GB)
    - https://www.amazon.com/dp/B06XWMQ81P
- Debian Installation Image (Server Images)
  - 4LTS - http://www.orangepi.org/html/hardWare/computerAndMicrocontrollers/service-and-support/Orange-pi-4-LTS.html
  - 5B - http://www.orangepi.org/html/hardWare/computerAndMicrocontrollers/service-and-support/Orange-Pi-5B.html
  - 3B - http://www.orangepi.org/html/hardWare/computerAndMicrocontrollers/service-and-support/Orange-Pi-3B.html
- IMG files can be installed on a microSD card using balenaEtcher
  - https://www.balena.io/etcher/

## Installation instructions ##
- Extract the installation image from the downloaded archive file
- Install it on your microSD card with balenaEtcher, and insert it into the side of the OPi4 board
- Plug in your USB webcam, mouse and keyboard
- The OPi4 LTS and 5B boards are equipped with WiFi, so have your network password on hand, or plug it in directly to ethernet
- Connect the OPi board to a display via an HDMI cable
- Finally, plug in the 5v/4 amp power adapter to power on the device

### Once the OPi4 board has completed booting, perform the following actions: ###
- Type the following in your console
```bash
sudo orangepi-config
```
- Select your wifi network
- Select your timezone
- Optional, but recommended: 
  - Set your hostname
  - Set a static IP

- Type the following commands in the terminal to update your system:
  - If you are prompted for a password, enter: orangepi
```bash
sudo apt update
sudo apt -y upgrade
```
- Reboot your device with the following commmand
```bash
sudo shutdown now -r
```

- Type (or copy and paste) each of the commands below into the terminal, one by one, and pressing the Enter key on your 
keyboard to submit the command.

```bash
cd ~
wget https://raw.githubusercontent.com/hobie2987/octoprint-orange-pi4-lts/main/install.sh
sudo bash ./install.sh
```

### The above commands perform the following actions ###
- cd ~ - Change directory to the root user's home directory
- wget https://... - This will download the install.sh script directly from GitHub
- sudo bash ./install.sh - Executes the installation script with super-user privileges

The script will take some time to run, maybe ~10 minutes or so, depending on your download speeds from your ISP.  During 
the installation process, you will be prompted a couple of times to confirm the installation of required packages. When
prompted, just press the "Y" key on the keyboard and press "Enter".  You will also be prompted to provide a password for 
your newly created "pi" user.  Pick something you will remember, but it is not that important because the script will 
disable the password requirement for user "pi".

### The installation script will perform the following actions for you ###
- Runs a system update/upgrade to ensure everything on your OPI4 is up-to-date
- Create sudo user "pi", and grant access to serial connections for communication with your 3D printer
- Downloads and installs all necessary Python packages to run OctoPrint
- Creates a virtual environment and installs OctoPrint.
  - It will also install the auto-start scripts so OctoPrint runs on system start
- Downloads and installs all necessary MJPG streamer packages
  - This will also install the auto start scripts for streaming services on system start
- Updates pi user permissions so sudo commands do not require a password
  - This is important, so you can restart and shutdown the system for the OctoPrint system menu
- Installs and configures a reverse-proxy so OctoPrint and webcam stream are accessible on port :80
- Enables all required services and auto-start scripts

Once the script completes successfully, it will display the following message:
```
'OctoPrint is now installed with webcam support!  Please reboot your system!'
'-------------------------------------------------------------------------------'
'OctoPrint is running @: http://192.168.X.X/'
'Webcam stream is running @: http://192.168.X.X/webcam/?action=stream'
'-------------------------------------------------------------------------------'
'System commands'
'Restart OctoPrint: sudo service octoprint restart'
'Restart System: sudo shutdown -r now'
'Shutdown System: sudo shutdown -h now'
'-------------------------------------------------------------------------------'
'Webcam & Timelapse Settings'
'Stream URL: /webcam/?action=stream'
'Snapshot URL: http://127.0.0.1:8080/?action=snapshot'
'Path to FFMPEG: /usr/bin/ffmpeg'
'-------------------------------------------------------------------------------'
```

Once you see this message, write down the OctoPrint URL, as you will need this for accessing and configuring 
OctoPrint.  The script will prompt you upon completion to restart your OPi by pressing the "R" key, or any other 
key to exit.  If you choose to exit without restart, you can restart your OPi at any time using the following command:

```bash
sudo shutdown -r now
```

## Post install instructions ##

Once your system has restarted, open a web browser on another computer and enter the URL you copied from the 
script output.  This should load the OctoPrint setup wizard.  During the setup process, there will be two steps for 
providing system command and URL's for your webcam.  Use the values provided below:

### Webcam and Timelapse settings ###
- Stream URL
  - /webcam/?action=stream
- Snapshot URL
  - http://127.0.0.1:8080/?action=snapshot
- Path to FFMPEG
  - /usr/bin/ffmpeg
  
### Ocotprint Shutdown/Restart commands ###
- Restart Octoprint
  - sudo service octoprint restart
- Restart system:
  - sudo shutdown -r now
- Shutdown system:
  - sudo shutdown -h now

## Adjusting webcam resolution and framerate ##

The webcam auto-start script will auto-detect the webcam device (/dev/video*), resolution and framerate.  This is done 
through a series of v4l2-ctl and udevadm commands to identify which /dev/video* device meets the following criteria.
```
ID_BUS=usb
ID_TYPE=video
ID_V4L_CAPABILITIES=:capture:
```

This does add some overhead, but can be beneficial if your webcam devname changes every time the Opi is rebooted.  If 
you find that your webcam settings are consistent, you can edit the webcamd script to set the following 
variables to bypass the auto-detection logic:

```bash
sudo nano /home/pi/scripts/webcamd
```

Then populate the following configuration variables at the top of the script with your desired values:

```bash
VIDEO_DEVICE=/dev/video0
VIDEO_RESOLUTION=1920x1080
VIDEO_FRAMERATE=30
```

Once you update the script, enter the following key combinations to save the change and exit out of the Nano editor
- Ctrl + X
- Y - Confirms save changes
- Enter

The script will ensure the provided resolution and framerate are supported.  If an unsupported resolution or framerate 
is supplied, the script will automatically apply the MAX resolution and framerate supported by the camera.

To restart your webcam device, run the following commands in your terminal restart your webcam service.
```bash
sudo systemctl stop webcamd
sudo systemctl start webcamd
```

If this still did not work, you can restart your system with the following command, and the new settings should be used
on system start
```bash
sudo shutdown -r now
```

