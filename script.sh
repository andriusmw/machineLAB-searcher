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
        echo -e "\n ${greenColour}[+] Downloading necessary files... ${endColour}"
        curl -s $main_url > bundle_temp.js
        ./node_modules/.bin/js-beautify -r bundle_temp.js &>/dev/null
        # indicates local path + -r to rewrite bundle_temp.js
        mv bundle_temp.js bundle.js
        # checks bundle.js was created
        if [ -s bundle.js ]; then
            echo -e "${greenColour}\n [+] bundle.js created and not empty... ${endColour}"
            rm -f bundle_temp.js 
        else 
            echo -e "\n ${redColour}[+] There has been an error formatting bundle.js ${endColour}"
             rm -f bundle_temp.js
             rm -f bundle.js
            return 1
        fi    
        echo -e "\n ${greenColour}[+] All files downloaded. ${endColour}"
  # IF FILE BUNDLE.JS EXISTS THEN DOWNLOADS AND COMPARES    
    else
        echo -e "\n ${yellowColour}[+] The file bundle.js exists ${endColour}"
        curl -s $main_url > bundle_temp.js
        ./node_modules/.bin/js-beautify -r bundle_temp.js &>/dev/null
        # indicates local path + -r to rewrite bundle_temp.js
        # Shows MD5 of files
        md5_Downloaded_value=$(md5sum bundle_temp.js | awk '{print $1}')
        md5_Local_value=$(md5sum bundle.js | awk '{print $1}')
        echo -e "\n ${greenColour} Downloaded version_MD5: ${md5_Downloaded_value} ${endColour}"
        echo -e "\n ${greenColour} Local version_MD5: ${md5_Local_value} ${endColour}"
        #  # compares the string value of those 2 vars
        if [ "$md5_Downloaded_value" == "$md5_Local_value" ]; then
           echo -e "\n you are already updated"
           rm -f bundle_temp.js
        else
            echo -e "\n ${greenColour} [+] there is a new version ${endColour}"
            sleep 2
            echo -e "\n ${greenColour} updating... ${endColour}"
            sleep 2
            rm bundle.js && mv bundle_temp.js bundle.js 
            # checks if bundle.js was created
            if [ -s bundle.js ]; then 
                echo -e " ${greenColour} \n [+] Updated, go hack some machines! ${endColour}"
                rm -f bundle_temp.js
            else 
                echo -e "\n${redColour} [!] there has been an error updating... ${endColour}"
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
  echo -e "${yellowColour}  -u Search for updates ${endColour}"
  echo -e "${yellowColour}  -m <machine_name> Search by machine name ${endColour}"
  echo -e "${yellowColour}  -i <ip_Address> Search by IP Address ${endColour}"
  echo -e "${yellowColour}  -d <difficulty> List all machines in a selected Difficulty. Available difficulties are :
                         Fácil - Media - Difícil - Insane 
                it means: Easy - Medium - Hard - Insane  \n ${endColour}" 
  echo -e "${yellowColour}  -o <os> Filter machines by Operating System. ${endColour}"             
  echo -e "${yellowColour}  -e <difficulty,os> Search by Difficulty AND by Operating System. Use ',' as delimitator
                                Example1 : -e Media,Windows 
                                Example2 : -e Insane,Linux
                                Note: Dificulties are the same of the -d parameter 
                                ( Fácil - Media - Difícil - Insane) \n ${endColour}"
echo -e "${yellowColour}  -s <Skill> Search by Skill. Example: -s SQLi  \
                              
  -s \"<Skill name>\" to search by compound names like 'Active Directory' for example.\n\
                                Note the \" \" to encapsulate the skill name.\n\
                                Example1: -s \"Active Directory\" \n\
                                Example2: -s \"Local File Inclusion\"\n\
                                ${endColour}"
                             
  echo -e "${yellowColour}  -h Show help ${endColour}"
}

# Function to search a machine by name
function searchMachineName(){
  local machineName="$1"
  echo -e "${greenColour}Searching machine name: ${machineName}${endColour}"

    echo -ne "${greenColour}"
    
   cat bundle.js | awk 'BEGIN{IGNORECASE=1} /name:.*'"$machineName"'/, /resuelta:/' | \
  grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//' | \
  awk '/^name:/ { if (NR != 1) print "";  }{ print }'
# this last awk prints a new "jump of line" each time it detects name except the first one
# grep -vE excludes id,sku and resuelta from results.
# tr -d cleans the output from symbols
# at the FIRST awk we ignore case and use symbols to enable partial results no matter spaces or ""

    echo -ne "${endColour}"
}

function searchMachineByIp(){
    local ipAddress="$1"
    echo -e "\n ${greenColour} ip address = $ipAddress ${endColour}"
    machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | \
        grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"
        # search a machine by ip and tries to save the name on the var machineName
    echo -e "\n ${greenColour} [+] the machine that matches IP: $ipAddress is: $machineName ${endColour}"
}


function FilterByMachinesDifficulty(){
    local difficulty=$1
    echo "difficulty= $difficulty"
    #checks that there are machines with that difficulty
    results_check="$(cat bundle.js | grep "dificultad: \"$difficulty\"" )"

    #shows name, ip, difficulty ( to double check) and youtube link of each matching machine.
    if [ -n "$results_check" ] ; then 
        echo -ne "\n ${greenColour} [+] These are the results for $difficulty ... \n"
        cat bundle.js | grep -E "dificultad:[[:space:]]*\"$difficulty\"" -B 5 -A 5 | \
            awk '/name:|ip:|youtube:|dificultad:/ { print } /youtube:/ { print "" }' 
        echo -ne " ${endColour}"    
    else
        echo -e " ${redColour}"
         echo -e " \n  The available difficulties are : Fácil - Media - Difícil - Insane   try a new search "
         echo -e " ${endColour}"
    fi
   
}

FilterByOs(){
    local OperatingSystem=$1
    os_results="$(cat bundle.js | grep "so: \"$OperatingSystem\"" -B 5 | grep "name: ")"
    # Checks if os_results has something
    if [ -n "$os_results" ]; then 
        echo -ne "\n ${greenColour}  [+] These are the machines matching the OS: $OperatingSystem ...\n"
       
        cat bundle.js | grep "so: \"$OperatingSystem\"" -B 5 | grep "name: "| \
            awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column 
        echo -ne "${endColour}"
    else
        echo -e "\n ${redColour} [!] could NOT find any machine with that OS, available options are: Windows - Linux ${endColour}"
    fi    
}

FilterByDifficulyAndOs(){
    local localDifficulty=$1
    local localOs=$2
    echo -e "\n ${greenColour}  [+] searching by Difficulty: $localDifficulty and by Os : $localOs \n ${endColour}"

    search_results=$(cat bundle.js | grep "so: \"$localOs\"" -C 4 | grep "dificultad: \"$localDifficulty\"" -B 5 | \
             grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)
    if [ -n "$search_results" ]; then 
    echo -ne "${greenColour}" 
     cat bundle.js | grep "so: \"$localOs\"" -C 4 | grep "dificultad: \"$localDifficulty\"" -B 5 | \
             grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column 
    echo -ne "${endColour}"
    else
        echo -e "\n ${redColour} [!] no data found with those parameters, try again. Example: -e Media,Windows ${endColour}"
    fi 

}

SearchBySkill(){
    local skill="$1"

    check_skill="$(cat bundle.js | grep "skills: " -B 6 | grep "$skill" -i -B 6 |  grep "name: " | awk 'NF{print $NF}' \
        | tr -d '"' | tr -d ',' | column)"

    if [ "$check_skill" ]; then 
        echo -e "\n searching by : $skill "
        echo -e "\n ${greenColour}"
        cat bundle.js | grep "skills: " -B 6  | grep "$skill" -i -B 6 | grep "name: " | awk 'NF{print $NF}' \
        | tr -d '"' | tr -d ',' | column
         echo -e "\n ${endColour}"
    else
        echo -e "\n ${redColour} [!] Could not find machines with that skill check the help menu and try again ${endColour}"
    fi


}


# Processing options with getopts
while getopts "m:hui:d:o:e:s:" arg; do
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
    s) SearchBySkill "$OPTARG" ;;
    h) helpPanel ;;
    *) helpPanel ;;
  esac
done