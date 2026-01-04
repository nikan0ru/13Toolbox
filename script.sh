#!/bin/bash
# ************************************************ #
#												   #
#			              %%%					   #
#			            %%+ %					   #
#			             : %@					   #
#			         %%@@@*@					   #
#			      %%%%:  .-@@@					   #
#			     %% @+%%:   +%					   #
#			   @     @ @#+: =@@					   #
#			   @    @+   =+-% %%%				   #
#			    @-   @@@+.+@@@@					   #
#			  #@@@+     .@@  ++ =@				   #
#			     #@   @+     #%%+ @				   #
#			       @+@+@@@@@@@   @#+@*			   #
#			     @@  @@++++=+=+@@   @*			   #
#			       @@* +@@%@== #@@+@			   #
#			        @@+@     @+  +@				   #
#			    :@@@-  @      %@+@*@			   #
#			  @@%%%%%@@@@@@=        @  :		   #
#			                @@@@@@@@@@@			   #
#                                                  #
#                                                  #
#                                                  #
#    Created: 2025/04/21 17:58:37 by yrhandou      #
#                                                  #
# *************************************************#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

Black='\033[0;30m'
Red='\033[0;31m'
Green='\033[0;32m'
Yellow='\033[0;33m'
Blue='\033[0;34m'
Purple='\033[0;35m'
Cyan='\033[0;36m'
ERR=1

bluetooth_mangler()
{
	declare -i i=0;
	declare -i paired_devices_count;
	declare -a paired_devices;
	declare -a devices_array;

	printf "Removing Bluetooth Devices\n"
	devices=$( bluetoothctl paired-devices )
	paired_devices_count=$(echo "$devices" | grep -c "Device" )
	IFS=$'\n' read -r -d '' -a devices_array <<< "$devices"
	if [[ $paired_devices_count -eq 0 ]]; then
		printf "$Yellow NO bluetooth device Paired , Exiting! $Black"
		return $ERR;
	fi;
	while [[ i -lt  $paired_devices_count ]] ;
	do
		device=$(echo "${devices_array[i]}" | awk ' {print $2}')
		paired_devices+=("$device");
		bluetoothctl untrust "${paired_devices[i]}";
		bluetoothctl disconnect "${paired_devices[i]}";
		bluetoothctl remove "${paired_devices[i]}";
		((i++));
	done
	return 0;
}

resolution()
{
	local RESOLUTION;

	if [[ -z "$1" ]]; then
		RESOLUTION="2560x1440"
	else
		RESOLUTION=$1
	fi
	xrandr -s "$RESOLUTION";
	printf  "$Green Changed Resolution Successfully $Black\n";
	return 0;
}

brightness()
{
	gdbus call --session --dest org.gnome.SettingsDaemon.Power --object-path /org/gnome/SettingsDaemon/Power \
	--method org.freedesktop.DBus.Properties.Set org.gnome.SettingsDaemon.Power.Screen Brightness "<int32 "$1">"
	printf  "$Green Changed Brightness Successfully $Black\n";
	return 0;

}

theme_switcher()
{
	if [[ "$1" == 'dark' || -z "$1" ]]; then
		DARK_THEME="Adwaita-dark";
		gsettings set org.gnome.desktop.interface gtk-theme $DARK_THEME
		gsettings set org.gnome.desktop.interface color-scheme prefer-dark
	elif [[ "$1" == 'light' ]]; then
		LIGHT_THEME="Adwaita";
		gsettings set org.gnome.desktop.interface gtk-theme $LIGHT_THEME
		gsettings set org.gnome.desktop.interface color-scheme prefer-light
	fi
	printf "$Green Changed Theme Successfully\n";
	return 0;
}

spotify_fix()
{
	rm -rf "$HOME/.var/app/com.spotify.Client"
	flatpak override --user --nosocket=wayland com.spotify.Client
	flatpak run com.spotify.Client
	return 0;
}

update_favourites()
{
	declare -a APPLICATIONS;

	printf "$Blue No Args Given ! Using default settings $Black"
	APPLICATIONS=( org.mozilla.firefox com.spotify.Client com.visualstudio.code)  # Applications That will be Updated
	flatpak update "${APPLICATIONS[@]}"  -y ;
}

default_settings()
{
	brightness
	# bluetooth_mangler
	resolution
	update_favourites
}

initial_startup()
{
	local response;
	local BluetoothDevice
	local NewState;
	local fontColor
	local BluetoothList

	NewState=$1;
	fontColor=$(gsettings get org.gnome.desktop.interface color-scheme)
	if [[ fontColor == "'prefer-dark'" ]]; then
		fontColor=$White
	else
		fontColor=$Black
	fi
	printf $Blue"Welcome to the initial setup, this page will appear only once \n"$fontColor
	printf $Blue"Set Resolution ? (y/n)"$fontColor
	read -r response
	response=${response,,}
	if [[ $response == 'y' || -z $response  ]]; then
		cat "$SCRIPT_DIR/display_resolutions_list"
		printf "Select a Resolution !\n"
		read -r response
		if [[ -z $response ]]; then
			resolution
			NewState=$(echo "$NewState" | jq '.Resolution = "2560x1440"')
		else
			resolution "${response,,}"
			NewState=$(echo "$NewState" | jq --arg res "${response,,}"'.Resolution = res')
		fi
	fi
	printf "%s\n" $NewState;
	printf $Blue"Set Theme ? (light/dark/n) (default == dark) "$fontColor
	read -r response
	response=${response,,}
	if [[ $response == 'light' || $response == 'dark'  || -z $response ]]; then
		theme_switcher $response
		fontColor=$(gsettings get org.gnome.desktop.interface color-scheme)
		if [[ fontColor == "'prefer-dark'" ]]; then
			fontColor=$White
		else
			fontColor=$Black
		fi
	fi
	printf $Blue"would you like to setup bluetooth mangler ? (y/n)"$fontColor
	read -r response
	response=${response,,}
	if [[ $response == 'y' || -z $response  ]]; then
		bluetooth_mangler
		printf $Blue"Connect your device then press ENTER!"$fontColor
		read -r response
		response=${response,,}
		BluetoothDevice=$(bluetoothctl paired-devices)
		printf "%s\n" "$BluetoothDevice"
		printf "is this your device ? (y/n)\n"
		read -r response
		response=${response,,}
		BluetoothList=$( bluetoothctl paired-devices)
		BlueToothDevice=$(echo $BluetoothList |awk '{print $2}' | head -n 1)
		bluetoothctl pair "$BluetoothDevice";
		bluetoothctl trust "$BluetoothDevice";
		bluetoothctl connect "$BluetoothDevice";
		# choose what you want out of this
		NewState=$(echo "$NewState" | jq "'.BluetoothDevices = $BluetoothDevice'")
		NewState=$(echo "$NewState" | jq "'.Bluetooth = $BluetoothDevice'")
	fi
	printf $Blue"What is your Browser? (firefox/brave/chrome )"$fontColor
	read -r response
	response=${response,,}
	NewState=$(echo "$NewState" | jq '.Browser = "$response"')

		# 	jq --arg Theme "${Theme,,}" '.preferredSystemTheme |= $Theme' userData.json  \
	# 	>> temp.json &&  mv temp.json userData.json
	# # elif [[ "${Response,,}" == "auto" ]]; then
	# # 	theme_switcher $Response
	# 	# set_timeswitch
	# else
	# 	printf $Red"\nInvalid Argument Try Again"$Black
	# 	initial_startup

}
main()
{
	GLOBAL_STATE=$(jq -c '.' "$SCRIPT_DIR/userData.json")
	read -r FreshStart IconType SystemTheme Resolution brightness <<< \
	"$(echo "$GLOBAL_STATE" | \
	jq -r '[.FreshStart, .IconType, .preferredSystemTheme, .Resolution, .brightnessLVL] | @tsv')"
	# if [[ $FreshStart == "false" && -z $1 ]]; then
	# 	printf "13Toolbox Hello! for arguments please refer to the README.md! :)"
	# 	return 0;
	# elif [[  $FreshStart == "true" ]]; then
	# 	initial_startup "$GLOBAL_STATE"
	# 	return 0;
	# fi

	# jq --arg FreshStart "$FreshStart" '.FreshStart |= false'
	# userData.json  >> temp.json &&  mv temp.json userData.json

	if [[ $1 = 'debug' ]]; then
		echo $FreshStart $IconType
	elif [[ $1 = '-bth' ]]; then
		bluetooth_mangler
	elif [[ $1 = '-t' ]]; then
		theme_switcher $SystemTheme
	elif [[ $1 = '-u' ]]; then
		update_favourites
	elif [[ $1 = '-d' ]]; then
		display $Resolution
	elif [[ $1 = '-b' ]]; then
		brightness $brightness
	elif [[ $1 = '-s' ]]; then
		spotify_fix
	elif [[ -z "$1" ]]; then
		default_settings
	else
		return $ERR;
	fi
}

main "$1" "$2"
