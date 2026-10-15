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
  echo -e "${yellowColour}[+] Instructions:${endColour}\n"
  echo -e "  -u Search for updates"
  echo -e "  -m <machine_name> Search by machine name"
  echo -e "  -i <ip_Address> Search by IP Address"
  echo -e "  -d <difficulty> List all machines in a selected Difficulty. Available difficulties are :
                         Fácil - Media - Difícil - Insane 
                it means: Easy - Medium - Hard - Insane"
  echo -e "  -h Show help"
}

# Function to search a machine by name
function searchMachineName(){
  local machineName="$1"
  echo -e "${greenColour}Searching machine name: ${machineName}${endColour}"

  cat bundle.js | awk  "/name: \"$machineName\"/,/resuelta:/" | \
    grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//'
    # the \ at the end is to continue on the next line.
    # with awk we are determining a range of results based on how we receive the data
    # with grep we are indicating parameters to ignore, with tr -d params to remove
    # sed removes empty spaces at the begining.
}

function searchMachineByIp(){
    local ipAddress="$1"
    echo -e "ip address = $ipAddress"
    machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | \
        grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"
        # search a machine by ip and tries to save the name on the var machineName
    echo -e "\n[+] the machine that matches IP: $ipAddress is: $machineName "
}


function FilterByMachinesDifficulty(){
    local difficulty=$1
    echo "difficulty= $difficulty"
    #checks that there are machines with that difficulty
    results_check="$(cat bundle.js | grep "dificultad: \"$difficulty\"" )"

    #shows name, ip, difficulty ( to double check) and youtube link of each matching machine.
    if [ -n "$results_check" ] ; then 
        echo -e "\n [+] These are the results for $difficulty ... \n "
        cat bundle.js | grep -E "dificultad:[[:space:]]*\"$difficulty\"" -B 5 -A 5 | \
            awk '/name:|ip:|youtube:|dificultad:/ { print } /youtube:/ { print "" }' 
    else
         echo -e"The available difficulties are : Fácil - Media - Difícil - Insane   try a new search"
    fi
   
}

FilterByOs(){
    local OperatingSystem=$1
    os_results="$(cat bundle.js | grep "so: \"$OperatingSystem\"" -B 5 | grep "name: ")"
    # Checks if os_results has something
    if [ -n "$os_results" ]; then 
        echo -e "\n[+] These are the machines matching the OS: $OperatingSystem ...\n"
        cat bundle.js | grep "so: \"$OperatingSystem\"" -B 5 | grep "name: "| \
            awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
    else
        echo -e "\n[!] could NOT find any machine with that OS, available options are: Windows - Linux"
    fi    
}

FilterByDifficulyAndOs(){
    local localDifficulty=$1
    local localOs=$2
    echo -e "\n[+] searching by Difficulty: $localDifficulty and by Os : $localOs \n"

    search_results=$(cat bundle.js | grep "so: \"$localOs\"" -C 4 | grep "dificultad: \"$localDifficulty\"" -B 5 | \
             grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)
    if [ -n "$search_results" ]; then 
        cat bundle.js | grep "so: \"$localOs\"" -C 4 | grep "dificultad: \"$localDifficulty\"" -B 5 | \
             grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
    else
        echo -e "\n no data found with those parameters, try again. Example: -e Media,Windows"
    fi 

}


# Processing options with getopts
while getopts "m:h:u:i:d:o:e:" arg; do
  case $arg in
    u) searchUpdates ;;
    m) searchMachineName "$OPTARG" ;;
    i) searchMachineByIp "$OPTARG" ;;
    d) FilterByMachinesDifficulty "$OPTARG";;
    o) FilterByOs "$OPTARG";;
    e)  
        # Separating arguments using IFS and read (,) as delimitator
        IFS=',' read -r difficulty os <<< "$OPTARG"
        # calling the function with separated arguments
        FilterByDifficulyAndOs "$difficulty" "$os";;
    h) helpPanel ;;
    *) helpPanel ;;
  esac
done