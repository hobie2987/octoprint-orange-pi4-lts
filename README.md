# OctoPrint Installer for Orange Pi (OPi) 4 LTS #

As we all know, Raspberry Pi's are hard to come by, and if you do find one, it comes with a ridiculous price tag.  I was
faced with this issue, so I sought out and alternate solution and purchased an Orange Pi 4 LTS board.  After purchasing,
I realized there was minimal support from the OctoPrint community, and saw this as an opportunity.  After many failed 
attempts of following the Linux install instructions, I finally learned there are gaps in the documentation.  Rather than 
documenting the process in depth so others do not make the same mistake, I instead scripted the installation process, 
and automation reduces the chances of making a mistake, causing you to restart the whole process over. 

## Requirements ##
- Orange Pi 4 LTS
  - Verified on the following versions
    - 4 GB RAM + 16 GB EMMC Flash storage
    - 3 GB RAM + Empty EMMC
- 8+ GB microSD card
  - I recommend Sandisk Ultra series (32GB)
    - https://www.amazon.com/dp/B08GY9NYRM
- Fresh installation of Armbian on microSD card
  - Installation IMG files can be downloaded from here: https://www.armbian.com/orange-pi-4-lts/
  - IMG files can be installed on a microSD card using balenaEtcher
    - https://www.balena.io/etcher/

## Installation instructions ##
- Extract the Armbian installation image from the downloaded archive file
- Install Armbian on your microSD card with balenaEtcher, and insert it into the side of the OPi4 board
- Plug in your USB webcam, mouse and keyboard
- The OPi4 LTS board is equipped with WiFi, so have your network password on hand, or plug it in directly to ethernet
- Connect the OPi4 board to a display via an HDMI cable
- Finally, plug in the 5v power adapter to power on the device

### Once the OPi4 board has completed booting, perform the following actions: ###
- Create a password for root, and confirm password
- Select your default shell
  - Press 1 for "bash"
- You will then be prompted to create a new sudo user. Use the following credentials
  - User Name: pi (all lowercase)
  - Password: your choice, but use something you'll remember
- Select your Wifi network (if applicable)
  - Select the SSID for your network
  - Enter the password/passphrase, use the down arrow and press ENTER on OK
  - Using your arrow keys, press right and then down to highlight "Quit", and hit Enter
- Select Language and Locale
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
```bash
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
OctoPrint.  At this time, restart your OPi4 by typing the following into your terminal

```bash
sudo shutdown -r now
```

## Post install instructions ##

Once your system has restarted, open a web browser on another computer and enter the URL you copied from the 
script output.  This should load the OctoPrint setup wizard.  During the setup process, there will be two steps for 
providing system command and URL's for your webcam.  Use the values provided below:

### Ocotprint Shutdown/Restart commands ###
- Restart Octoprint
  - sudo service octoprint restart
- Restart system:
  - sudo shutdown -r now
- Shutdown system:
  - sudo shutdown -h now

### Webcam and Timelapse settings ###
- Stream URL
  - /webcam/?action=stream
- Snapshot URL
  - http://127.0.0.1:8080/?action=snapshot
- Path to FFMPEG
  - /usr/bin/ffmpeg


## Adjusting webcam resolution and framerate ##

The webcam auto-start script has a hard coded value of 1080p/30fps resolution/framerate, which might not be compatible with 
your webcam and could prevent your streaming services from starting properly.
```bash
camera_usb_options="-r 1920x1080 -f 30"
```
If this is not the correct resolution or framerate for your webcam, you can update the script with the correct ones by 
doing the following:

```bash
$ sudo su pi
$ sudo nano /home/pi/scripts/webcamd
```

This will enter the Nano editor, for modifying the script.  Use the arrow keys on your keyboard to navigate to the 
"camera_usb_options=" line and update the resolution and framerate to what you desire.  For example, to switch to 
720p/25fps:
```bash
camera_usb_options="-r 1280x720 -f 25"
```
Once you update the script, enter the following key combinations to save the change and exit out of the Nano editor
- Ctrl + X
- Y - Confirms save changes
- Enter

Once that change is made, in your terminal, run the following command to stop and restart your webcam service.
```bash
sudo systemctl stop webcamd
sudo systemctl start webcamd
```

If this still did not work, you can restart your system with the following command, and the new settings should be used
on system start
```bash
sudo shutdown -r now
```

