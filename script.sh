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


# global variables
main_url="https://htbmachines.github.io/bundle.js"

# Function to handle Ctrl+C (INT)
function ctrl_c(){
  echo -e "\n${redColour}[!] Exitting...${endColour}"
  exit 1
}

trap ctrl_c INT

# Function to seacrh updates
function searchUpdates(){
  echo -e "${greenColour}Searching Updates...: ${endColour}"
  # IF FILE BUNDLE.JS DOES NOT EXISTS THEN DOWNLOADS
    if [ ! -f bundle.js ]; then
        echo -e "\n [+] Downloading necessary files..."
        curl -s $main_url > bundle_temp.js
        ./node_modules/.bin/js-beautify -r bundle_temp.js &>/dev/null
        # indicates local path + -r to rewrite bundle_temp.js
        mv bundle_temp.js bundle.js
        if [ bundle.js ]; then
            echo -e "\n [+] bundle.js formated..."
            rm -f bundle_temp.js 
        else 
            echo -e "\n [+] There has been an error formatting bundle.js"
             rm -f bundle_temp.js
             rm -f bundle.js
            return 1
        fi    
        echo -e "\n [+] All files downloaded."
  # IF FILE BUNDLE.JS EXISTS THEN DOWNLOADS AND COMPARES    
    else
        echo -e "\n [+] The file bundle.js exists"
        curl -s $main_url > bundle_temp.js
        ./node_modules/.bin/js-beautify -r bundle_temp.js &>/dev/null
        # indicates local path + -r to rewrite bundle_temp.js
        # Compares with md5sum
        md5_Downloaded_value=$(md5sum bundle_temp.js | awk '{print $1}')
        md5_Local_value=$(md5sum bundle.js | awk '{print $1}')
        echo -e "\n Downloaded version_MD5: ${md5_Downloaded_value}"
        echo -e "\n Local version_MD5: ${md5_Local_value}"
    fi


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
while getopts "m:h:u" arg; do
  case $arg in
    u) searchUpdates ;;
    m) searchMachine "$OPTARG" ;;
    h) helpPanel ;;
    *) helpPanel ;;
  esac
done