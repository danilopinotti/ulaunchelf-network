#!/bin/bash

#CONFIG
path=./
newperm=775
configfile="./.config"
IPPS2=""

function checkPermissions(){
	clear
	if [ $(stat -c %a "$path") != $newperm ] || [ $(stat -c %a "./ps2client") != $newperm ] || [ $(stat -c %a "./open.sh") != $newperm ]; then
		echo "Uma ou mais permissões estão incorretas. Iremos corrigir isso para você."
		sudo chmod -R $newperm ./
		sudo chmod -R $newperm ./ps2client
		sudo chmod -R $newperm ./open.sh	
		echo "Permissões alteradas!"
		echo ""
	fi
}

function loadConfig(){
	if [ -f "$configfile" ]
	then
		. $configfile
	else
		echo "IPPS2=0.0.0.0" > $configfile
		. $configfile
	fi
}

function changeConfigs(){
	local option="0"
	while [ $option -eq "0" ]
	do 
		local IPPC=$(ip addr list eth0 |grep "inet " |cut -d' ' -f6|cut -d/ -f1)
		$option="0"
		clear
		echo "IP do PS2: $IPPS2"
		echo "IP do Computador: $IPPC" 
		echo "Opções: "
		echo "  [1] - Alterar IP do PS2."
		#echo "  [2] - Alterar IP do PC."
		echo "  [Enter] - Continuar."
		read option
		case $option in
			1) consoleConfig;;
		  # 2) computerConfig;;
			*) echo "Continuando...";;
		esac
	done
	saveConfig
}

function consoleConfig(){
		local option
		echo "O atual IP do PS2 é $IPPS2"
		echo "Digite o novo IP do PS2. Deixe em branco caso não queira alterar."
		read option
		if [ ! -z $option ] 
		then
			IPPS2=$option
		fi
}

#function computerConfig(){
#		local IPPC=$(ip addr list eth0 |grep "inet " |cut -d' ' -f6|cut -d/ -f1)
#		local option="0"
#		echo "O que deseja fazer ?"
#		echo " [1] - Configurar IP estático"
#		echo " [2] - Usar DHCP"
#		echo " [Enter] - Voltar"
#		read option
#		if [ "$option" = "1" ] 
#		then
#			echo "O atual IP do computador é $IPPC"
#			echo "Digite o novo IP do PC. Deixe em branco caso não queira alterar."
#			read option
#			if [ ! -z $option ] 
#			then
#				sudo ifconfig eth0 $option netmask 255.255.255.0
#				sudo ifdown eth0
#				sudo ifup eth0
#			fi
#		elif [ "$option" = "2" ]
#		then
#			sudo dhclient eth0
#			sudo ifdown eth0
#			sudo ifup eth0
#		fi
#}

function saveConfig(){
		echo "IPPS2=$IPPS2" > $configfile	
}

function executeClient(){
	clear
	echo "PS2 Client iniciado para $IPPS2"
	echo "Para encerrar, aperte CTRL + C"
	./ps2client -h $IPPS2 listen
}

function run(){
	checkPermissions
	loadConfig
	changeConfigs
	executeClient
}

run
