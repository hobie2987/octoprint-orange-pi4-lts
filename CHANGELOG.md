
# Change Log
All notable changes to this project will be documented in this file.

## [2023-07-08]

### Changed
- List supported resolutions by detected webcam
- List device details (auto & provided devices)
- Remove debug echos for resolutions and frame rates
---

## [2023-06-22]
### Summary
Enhancements to install and webcamd startup script

### Added
- Install supporting usb_webcam.sh script
- Validate valid resolution and framerate
- Add -y option for apt install, update, and upgrade

### Changed
- Flatten webcamd script
---

## [2023-06-17]
### Summary
Enhancements to webcamd startup script

### Added
- 1 minute poll to detect webcam
- Auto-detect webcam device (ex: /dev/video0)
- Auto-detect webcam resolution
- Auto-detect webcam resolution
---

## [2023-06-14]
### Summary
Script optimization/cleanup and support for Orange Pi 5/5B (Debian)!

### Added
- Use /home/pi/tmp directory to initially store services and scripts.
- Install v4l-utils package for webcam discovery
- Auto-detect USB Webcam devname in webcamd script
- Prompt user to reboot
### Changed
- Consolidate package installs
- Consolidate fetching of service scripts
- Consolidate pi group assignments
- Consolidate creation of necessary directories
- Removed RaspPi-cam specific logic from webcamd.  Support USB Webcam ONLY
---

## [2023-06-13]
### Fixed
- Change "apt-get" to "apt"
- Add pi user to video group
---

## [2022-07-29]
### Added
- Support Armbian and Debian
### Fixed
- Install package libjpeg-dev, removed libjpeg62-turbo-dev
- Use variable for Webcam devname (/dev/video*), removed assumption webcam is /dev/video0
- set user as "pi" in webcamd.service
---

## [2022-07-28]
### Fix-d
- Add pi user to tty and dialout groups
---

## [2022-05-07]
### Fixed
- Fix access permissions on /home/pi/OctoPrint id initially created by root
---

## [2022-05-05]
### Added
- Output webcam and timelapse settings at end of script
---

## [2022-05-04]
### Added
- Automate reverse proxy configuration to enable OctoPrint and Webcam on port 80
### Fixed
- Fixed octoprint.service name in webcamd.service
- Check if user pi exists before creation attempt
- Set user pi permissions for webcamd script (read/execute)
---

## [2022-05-03]
- Initial revision
