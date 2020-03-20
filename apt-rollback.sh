#!/bin/bash
# Ubuntu apt-RollBack Script
# By Fabio Dell'Aria - fabio.dellaria@gmail.com - Mar 2020

# Check if the current user is "root" otherwise restart the script with "sudo"...
[ "$(whoami)" != "root" ] && exec sudo -- "$0" "$@"

# Instruct the Script to Abort for any command error...
set -e

echo "Ubuntu apt-RollBack Script - ver. 0.3.1"
echo "---------------------------------------"

# Main Variables...
INSTALLED_PACKAGES=$(grep -A4 "Start-Date:" /var/log/apt/history.log | tail -5 | grep "Install: " | cut -d" " -f2- | sed "s/[(][^)]*[)]//g" | sed "s/ ,//g")
REMOVED_PACKAGES=$(grep -A4 "Start-Date:" /var/log/apt/history.log | tail -5 | grep -e "Purge: " -e "Remove: " | cut -d" " -f2- | sed "s/[(][^)]*[)]//g" | sed "s/ ,//g")

# Remove last Installed Packages...
apt purge "$INSTALLED_PACKAGES"

# Install last Removed Packages...
apt install "$REMOVED_PACKAGES"
