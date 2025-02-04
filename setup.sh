#!/bin/bash

# Prompt user for Home Assistant (or other) URL
read -p "Enter the URL for the kiosk (e.g., http://homeassistant.local:8123): " kiosk_url

# Update system and install required packages
echo "Updating system and installing required packages..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y chromium-browser xserver-xorg x11-xserver-utils xinit unclutter

# Enable auto-login to the desktop
echo "Setting up auto-login..."
sudo raspi-config nonint do_boot_behaviour B4

# Set up the Chromium autostart script
echo "Configuring Chromium to launch in kiosk mode with URL: $kiosk_url..."
mkdir -p ~/.config/lxsession/LXDE-pi
cat <<EOF > ~/.config/lxsession/LXDE-pi/autostart
@lxpanel --profile LXDE-pi
@pcmanfm --desktop --profile LXDE-pi
@xset s off
@xset -dpms
@xset s noblank
@unclutter -idle 0.5 -root
@chromium-browser --noerrdialogs --disable-infobars --kiosk $kiosk_url
EOF

# Disable screen blanking (optional)
echo "Disabling screen blanking..."
cat <<EOF >> ~/.xsessionrc
xset s off
xset -dpms
xset s noblank
EOF

# Set script permissions
chmod +x ~/.config/lxsession/LXDE-pi/autostart

echo "Setup complete! Reboot your Raspberry Pi to apply changes."
echo "You can restart now using: sudo reboot"
