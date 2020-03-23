#!/bin/bash
# Ubuntu apt-rollback Script
# By Fabio Dell'Aria - fabio.dellaria@gmail.com - Mar 2020

# Check if the current user is "root" otherwise restart the script with "sudo"...
[ "$(whoami)" != "root" ] && exec sudo -- "$0" "$@"

# Instruct the Script to Abort for any command error...
set -e

# Main Variables...
# --------------------------------------------------------------------------------
LOG_FILE=/var/log/apt/history.log
VERSION="0.6.5" # Use always the 'x.y.z' format 
# --------------------------------------------------------------------------------

# Main Functions...
# --------------------------------------------------------------------------------
function undo_last_command ()
{
  INSTALLED_PACKAGES=$(grep -A4 "Start-Date:" $LOG_FILE | tail -5 | grep "Install: " | cut -d" " -f2- | sed "s/[(][^)]*[)]//g" | sed "s/ ,//g" | sed 's/ *$//g')
  REMOVED_PACKAGES=$(grep -A4 "Start-Date:" $LOG_FILE | tail -5 | grep -e "Purge: " -e "Remove: " | cut -d" " -f2- | sed "s/[(][^)]*[)]//g" | sed "s/ ,//g" | sed 's/ *$//g')
  UPGRADED_PACKAGES=$(grep -A4 "Start-Date:" $LOG_FILE | tail -5 | grep "Upgrade: " | cut -d" " -f2- | sed "s/[(][^)]*[)]//g" | sed "s/ ,//g" | sed 's/ *$//g')
}

function usage_message ()
{
  echo "Usage: apt-rollback [--last] [--remove/--install package-name] [--help]"
}

function Yes_No ()
{
  WARNING=""
  while true; do
    read -r -p "$WARNING$1 [y/N]? " YESNO
    if [ -z "$YESNO" ]; then
      echo "n"
      break
    else
      case $YESNO in
        y|Y)
          echo "y"
          break;;
        n|N])
          echo "n" 
          break;;
        * ) WARNING="Please answer [y]es or [n]o."$'\n';;
      esac
    fi
  done
}
# --------------------------------------------------------------------------------

# Main Code...
# --------------------------------------------------------------------------------
echo "apt-rollback ver. $VERSION"
echo "Undo the last APT command or a specified one"
echo

if [ ! -f "$LOG_FILE" ]; then
  echo "The APT log file '$LOG_FILE' doesn't exist."
  echo
  exit 1
fi

if [ $# -eq 0 ]; then
  echo "No arguments supplied."
  usage_message
  echo
  ANSWER=$(Yes_No "Do you wish to see the last APT command")
  if [ "$ANSWER" == "y" ]; then
    echo
    undo_last_command
  fi
else
  case "$1" in
    "--last") undo_last_command
      ;;
    "--remove") INSTALLED_PACKAGES=$(grep -m1 "Install: $2:" $LOG_FILE | cut -d" " -f2- | sed "s/[(][^)]*[)]//g" | sed "s/ ,//g" | sed 's/ *$//g')
      ;;
    "--install") REMOVED_PACKAGES=$(grep -m1 -e "Purge: $2:" -e "Remove: $2:" $LOG_FILE | cut -d" " -f2- | sed "s/[(][^)]*[)]//g" | sed "s/ ,//g" | sed 's/ *$//g')
      ;;
    "--help") 
      usage_message
      echo
      echo "  --last      Undo the last APT command"
      echo "              Supports the undo of the only Install, Remove and Purge commands"
      echo "  --remove    Remove an INSTALLED package and all its configuration files"
      echo "              Removing also all its first installed dependencies"
      echo "  --install   Install a REMOVED package and all its first installed dependences"
      echo "              Reproducing exactly its first installation"
      echo "  --help      Print this help"
      echo
      exit
      ;;
    *) echo "'$1' is a wrong parameter"
      ;;
  esac
fi

if  [ -n "$INSTALLED_PACKAGES" ]; then
  echo "The last APT command was the Installation of the following packages: $INSTALLED_PACKAGES"
  ANSWER=$(Yes_No "Do you wish to Undo it?")
  if [ "$ANSWER" == "y" ]; then
    # Remove last Installed Packages...
    apt purge -y "$INSTALLED_PACKAGES"
    echo "Done"
  fi
else
  if  [ -n "$REMOVED_PACKAGES" ]; then
    echo "The last APT command was the Removing of the following packages: $REMOVED_PACKAGES"
    ANSWER=$(Yes_No "Do you wish to Undo it?")
    if [ "$ANSWER" == "y" ]; then
      # Install last Removed Packages...
      apt install -y "$REMOVED_PACKAGES"
      echo "Done"
    fi
  else
    if  [ -n "$UPGRADED_PACKAGES" ]; then
      echo "The last APT command was an Upgrade ($UPGRADED_PACKAGES)."
      echo "Currently, apt-rollback can undo only Installs and Removes/Purges operations."
      echo
    else
      echo "No operation to undo found."
      echo
    fi
  fi
fi

