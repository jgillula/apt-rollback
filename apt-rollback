#!/bin/bash
# apt-rollback Script
# By Fabio Dell'Aria - fabio.dellaria@gmail.com - Mar 2020

# Check if the current user is "root" otherwise restart the script with "sudo"...
[ "$(whoami)" != "root" ] && exec sudo -- "$0" "$@"

# Instruct the Script to Abort for any command error...
set -e

# Main Variables...
# --------------------------------------------------------------------------------
LOG_FILE=/var/log/apt/history.log
VERSION="0.8.0" # Use always the 'x.y.z' format
OPERATION="selected"
# --------------------------------------------------------------------------------

# Main Functions...
# --------------------------------------------------------------------------------
function undo_last_command ()
{
  OPERATION="last"
  INSTALLED_PACKAGES=$(grep -A4 "Start-Date:" $LOG_FILE | tail -5 | grep "Install: " | cut -d" " -f2- | sed "s/[(][^)]*[)]//g" | sed "s/ ,//g" | sed 's/ *$//g')
  REMOVED_PACKAGES=$(grep -A4 "Start-Date:" $LOG_FILE | tail -5 | grep -e "Purge: " -e "Remove: " | cut -d" " -f2- | sed "s/[(][^)]*[)]//g" | sed "s/ ,//g" | sed 's/ *$//g')
  UPGRADED_PACKAGES=$(grep -A4 "Start-Date:" $LOG_FILE | tail -5 | grep "Upgrade: " | cut -d" " -f2- | sed "s/[(][^)]*[)]//g" | sed "s/ ,//g" | sed 's/ *$//g')
}

function usage_message ()
{
  echo "Usage: apt-rollback [--last] [--remove/--reinstall package-name] [--help]"
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

function First_Installation ()
{
  OUTPUT=$(grep -m1 -E "Install: .*$1:" $LOG_FILE | cut -d" " -f2- | sed "s/[(][^)]*[)]//g" | sed "s/ ,//g" | sed 's/ *$//g')
  echo "$OUTPUT"
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
    "--remove") INSTALLED_PACKAGES=$(First_Installation "$2")
      ;;
    "--reinstall") REMOVED_PACKAGES=$(First_Installation "$2")
      ;;
    "--help") 
      usage_message
      echo
      echo "  --last       Undo the last APT command"
      echo "               Supports the undo of the only Install, Remove and Purge commands"
      echo
      echo "  --remove     Remove an INSTALLED package and related configuration files"
      echo "               Removing also all its first installed dependencies"
      echo
      echo "  --reinstall  Reinstall a REMOVED package,"
      echo "               and all its first installed dependences"
      echo "               Reproducing exactly its first installation"
      echo
      echo "  --help       Print this help"
      echo
      exit
      ;;
    *) echo "'$1' is a wrong parameter"
      ;;
  esac
fi

if  [ -n "$INSTALLED_PACKAGES" ]; then
  echo -e "The $OPERATION APT command, performed the 'INSTALL' of the following packages: \e[1;32m$INSTALLED_PACKAGES\e[0m"
  echo
  ANSWER=$(Yes_No "Do you wish to REMOVE them?")
  if [ "$ANSWER" == "y" ]; then
    echo
    echo -n -e "Working:\e[1;32m"
    # Remove last Installed Packages...
    apt-get purge -y -qq $INSTALLED_PACKAGES > /dev/null &
    #  echo dots while command is executing
    while ps | grep $! &>/dev/null; do
      echo -n "."
      sleep 0.5
    done
    echo
    echo -e "\e[0mDone"
    echo
  fi
else
  if  [ -n "$REMOVED_PACKAGES" ]; then
    echo -e "The $OPERATION APT command, performed the 'REMOVE' of the following packages: \e[1;32m$REMOVED_PACKAGES\e[0m"
    echo
    ANSWER=$(Yes_No "Do you wish to RE-INSTALL them?")
    if [ "$ANSWER" == "y" ]; then
      echo
      echo -n -e "Working:\e[1;32m"
      # Install last Removed Packages...
      apt-get install -y -qq $REMOVED_PACKAGES > /dev/null &
      #  echo dots while command is executing
      while ps | grep $! &>/dev/null; do
        echo -n "."
        sleep 0.5
      done
      echo
      echo -e "\e[0mDone"
      echo
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

