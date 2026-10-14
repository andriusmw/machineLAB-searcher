#!/bin/bash

# Definition of colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

# Function to handle Ctrl+C (INT)
function ctrl_c(){
  echo -e "\n${redColour}[!] Exitting...${endColour}"
  exit 1
}

trap ctrl_c INT

# Function to seacrh updates
function searchUpdates(){
  echo -e "${greenColour}Searching Updates...: ${endColour}"
}


# Function to show help
function helpPanel(){
  echo -e "${yellowColour}[+] Instructions:${endColour}"
  echo -e "  -u Search for updates"
  echo -e "  -m <machine_name> Search for machine name"
  echo -e "  -h                Show help"
}

# Function to seacrh a machine by name
function searchMachine(){
  local machineName="$1"
  echo -e "${greenColour}Searching machine: ${machineName}${endColour}"
}

# Processing options with getopts
while getopts "m:h" arg; do
  case $arg in
    u) searchUpdates ;;
    m) searchMachine "$OPTARG" ;;
    h) helpPanel ;;
    *) helpPanel ;;
  esac
done