#!/bin/bash

# Function to validate and fix the URL
fix_url() {
    local url=$1

    # Add "http://" if missing
    if [[ ! $url =~ ^https?:// ]]; then
        url="http://$url"
    fi

    # Add port 8123 if missing
    if [[ ! $url =~ :[0-9]+$ ]]; then
        url="$url:8123"
    fi

    echo "$url"
}

# Prompt user for Home Assistant (or other) URL
read -p "Enter the URL for the kiosk (e.g., homeassistant.local or http://192.168.1.100:8123): " input_url

# Fix the URL if necessary
kiosk_url=$(fix_url "$input_url")

echo "Using kiosk URL: $kiosk_url"

# Update system and install required packages
echo "Updating system and installing required packages..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y chromium-browser xserver-xorg x11-xserver-utils xinit unclutter

# Enable auto-login to the desktop
echo "Setting up auto-login..."
sudo raspi-config nonint do_boot_behaviour B4

# Set up the Chromium autostart script
echo "Configuring Chromium to launch in kiosk mode..."
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

# Ask the user if they want to reboot
read -p "Setup complete! Do you want to reboot now? (y/n): " reboot_choice

if [[ "$reboot_choice" == "y" || "$reboot_choice" == "Y" ]]; then
    echo "Rebooting now..."
    sudo reboot
else
    echo "You can reboot later using: sudo reboot"
fi
