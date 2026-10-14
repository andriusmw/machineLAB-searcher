#!/bin/bash

# Definición de colores para salida en terminal
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

# Función para manejar Ctrl+C (INT)
function ctrl_c(){
  echo -e "\n${redColour}[!] Saliendo...${endColour}"
  exit 1
}

trap ctrl_c INT

# Función para mostrar ayuda
function helpPanel(){
  echo -e "${yellowColour}[+] Uso:${endColour}"
  echo -e "  -m <nombre_maquina>   Buscar máquina por nombre"
  echo -e "  -h                   Mostrar este panel de ayuda"
}

# Función para buscar máquina y mostrar el nombre recibido
function searchMachine(){
  local machineName="$1"
  echo -e "${greenColour}Buscando máquina: ${machineName}${endColour}"
}

# Procesamiento de opciones con getopts
while getopts "m:h" arg; do
  case $arg in
    m) searchMachine "$OPTARG" ;;
    h) helpPanel ;;
    *) helpPanel ;;
  esac
done