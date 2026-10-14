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
        # checks bundle.js was created
        if [ -s bundle.js ]; then
            echo -e "\n [+] bundle.js created and not empty..."
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
        # Shows MD5 of files
        md5_Downloaded_value=$(md5sum bundle_temp.js | awk '{print $1}')
        md5_Local_value=$(md5sum bundle.js | awk '{print $1}')
        echo -e "\n Downloaded version_MD5: ${md5_Downloaded_value}"
        echo -e "\n Local version_MD5: ${md5_Local_value}"
        #  # compares the string value of those 2 vars
        if [ "$md5_Downloaded_value" == "$md5_Local_value" ]; then
           echo -e "\n you are already updated"
           rm -f bundle_temp.js
        else
            echo -e "\n there is a new version"
            sleep 2
            echo -e "\n updating..."
            sleep 2
            rm bundle.js && mv bundle_temp.js bundle.js 
            # checks if bundle.js was created
            if [ -s bundle.js ]; then 
                echo -e "\n Updated, go hack some machines!"
                rm -f bundle_temp.js
            else 
                echo -e "\n there has been an error updating..."
                rm -f bundle_temp.js
                rm -f bundle.js
                return 1
            fi
            
        fi


    fi


}


# Function to show help
function helpPanel(){
  echo -e "${yellowColour}[+] Instructions:${endColour}"
  echo -e "  -u Search for updates"
  echo -e "  -m <machine_name> Search for machine name"
  echo -e "  -h                Show help"
}

# Function to search a machine by name
function searchMachine(){
  local machineName="$1"
  echo -e "${greenColour}Searching machine name: ${machineName}${endColour}"

  cat bundle.js | awk  "/name: \"$machineName\"/,/resuelta:/" | \
    grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//'
    # the \ at the end is to continue on the next line.
    # with awk we are determining a range of results based on how we receive the data
    # with grep we are indicating parameters to ignore, with tr -d params to remove
    # sed removes empty spaces at the begining.
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