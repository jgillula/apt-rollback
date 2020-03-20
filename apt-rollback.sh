#!/bin/bash
# Ubuntu apt-RollBack Script
# By Fabio Dell'Aria - fabio.dellaria@gmail.com - Mar 2020

# Check if the current user is "root" otherwise restart the script with "sudo"...
[ "$(whoami)" != "root" ] && exec sudo -- "$0" "$@"

# Instruct the Script to Abort for any command error...
set -e

echo "Ubuntu apt-RollBack Script - ver. 0.3.3"
echo "---------------------------------------"

# Main Variables...

LOG_FILE=/var/log/apt/history.log

if [ ! -f "$LOG_FILE" ]; then
  echo "The APT log file '$LOG_FILE' doesn't exist."
  echo
  exit 1
fi

INSTALLED_PACKAGES=$(grep -A4 "Start-Date:" $LOG_FILE | tail -5 | grep "Install: " | cut -d" " -f2- | sed "s/[(][^)]*[)]//g" | sed "s/ ,//g" | sed 's/ *$//g')
REMOVED_PACKAGES=$(grep -A4 "Start-Date:" $LOG_FILE | tail -5 | grep -e "Purge: " -e "Remove: " | cut -d" " -f2- | sed "s/[(][^)]*[)]//g" | sed "s/ ,//g" | sed 's/ *$//g')
UPGRADED_PACKAGES=$(grep -A4 "Start-Date:" $LOG_FILE | tail -5 | grep "Upgrade: " | cut -d" " -f2- | sed "s/[(][^)]*[)]//g" | sed "s/ ,//g" | sed 's/ *$//g')

if  [ -n "$INSTALLED_PACKAGES" ]; then
  # Remove last Installed Packages...
  apt purge "$INSTALLED_PACKAGES"
else
  if  [ -n "$REMOVED_PACKAGES" ]; then
    # Install last Removed Packages...
    apt install "$REMOVED_PACKAGES"
  else
    if  [ -n "$UPGRADED_PACKAGES" ]; then
      echo "The last APT command was an Upgrade ($UPGRADED_PACKAGES)."
      echo "Currently, apt-rollback can reverse only Installs and Removes/Purges operations."
      echo
    else
      echo "No operation, to be reversed found."
      echo
    fi
  fi
fi

