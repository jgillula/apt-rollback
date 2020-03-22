#!/bin/bash
# Ubuntu apt-RollBack Script
# By Fabio Dell'Aria - fabio.dellaria@gmail.com - Mar 2020

# Check if the current user is "root" otherwise restart the script with "sudo"...
[ "$(whoami)" != "root" ] && exec sudo -- "$0" "$@"

# Instruct the Script to Abort for any command error...
set -e


# Main Variables...
LOG_FILE=/var/log/apt/history.log


# Main Functions...
function reverse_last_command ()
{
  INSTALLED_PACKAGES=$(grep -A4 "Start-Date:" $LOG_FILE | tail -5 | grep "Install: " | cut -d" " -f2- | sed "s/[(][^)]*[)]//g" | sed "s/ ,//g" | sed 's/ *$//g')
  REMOVED_PACKAGES=$(grep -A4 "Start-Date:" $LOG_FILE | tail -5 | grep -e "Purge: " -e "Remove: " | cut -d" " -f2- | sed "s/[(][^)]*[)]//g" | sed "s/ ,//g" | sed 's/ *$//g')
  UPGRADED_PACKAGES=$(grep -A4 "Start-Date:" $LOG_FILE | tail -5 | grep "Upgrade: " | cut -d" " -f2- | sed "s/[(][^)]*[)]//g" | sed "s/ ,//g" | sed 's/ *$//g')
}

function usage_message ()
{
  echo "Usage: apt-rollback [--last] [--remove package-name] [--install package-name]";
}

# Main Code...
echo "Ubuntu apt-RollBack Script - ver. 0.4.5"
echo "---------------------------------------"

if [ ! -f "$LOG_FILE" ]; then
  echo "The APT log file '$LOG_FILE' doesn't exist."
  echo
  exit 1
fi

if [ "$1" == "--last" ]; then
  reverse_last_command;
fi

if [ "$1" == "--remove" ]; then
  INSTALLED_PACKAGES=$(grep -m1 "Install: $2:" $LOG_FILE | cut -d" " -f2- | sed "s/[(][^)]*[)]//g" | sed "s/ ,//g" | sed 's/ *$//g')
fi

if [ "$1" == "--install" ]; then
  REMOVED_PACKAGES=$(grep -m1 -e "Purge: $2:" -e "Remove: $2:" $LOG_FILE | cut -d" " -f2- | sed "s/[(][^)]*[)]//g" | sed "s/ ,//g" | sed 's/ *$//g')
fi

if [ $# -eq 0 ]; then
  echo "No arguments supplied.";
  usage_message;
  while true; do
    read -r -p "Do you wish to reverse the last APT command (y/n)? " -e -i"n" Answer
    case $Answer in
        [y] )
          reverse_last_command;
          break;;
        [n] ) 
          break;;
        * ) echo "Please answer [y]es or [n]o.";;
    esac
  done
else
  echo "'$1' is a wrong parameter";
  usage_message;
fi

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

