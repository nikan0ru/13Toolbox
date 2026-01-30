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

bluetooth_mangler()
{
	declare -i i=0;
	declare -i paired_devices_count;
	declare -a paired_devices;
	declare -a devices_array;

	devices=$( bluetoothctl paired-devices )
	paired_devices_count=$(echo "$devices" | grep -c "Device" )
	IFS=$'\n' read -r -d '' -a devices_array <<< "$devices"
	if [[ $paired_devices_count -eq 0 ]]; then
		printf "No bluetooth device Paired , Exiting!"
		return 1;
	fi;
	printf "Removing Bluetooth Devices\n"
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
		RESOLUTION="2560x1440" # This will be used By default settings
	else
		RESOLUTION=$1
	fi
	xrandr -s "$RESOLUTION";
	printf  "Changed Resolution Successfully\n";
	return 0;
}

brightness()
{
	local -i LVL

	if [[ -z $1 ]];then
		LVL=10
	else
		LVL=$1
	fi
	gdbus call --session --dest org.gnome.SettingsDaemon.Power --object-path /org/gnome/SettingsDaemon/Power \
	--method org.freedesktop.DBus.Properties.Set org.gnome.SettingsDaemon.Power.Screen Brightness "<int32 "$LVL">"
	printf  "Changed Brightness Successfully\n";
	return 0;

}

theme_switcher()
{
	if [[ "$1" == 'dark' || -z "$1" ]]; then
		DARK_THEME="Adwaita-dark";
		gsettings set org.gnome.desktop.interface gtk-theme $DARK_THEME
		gsettings set org.gnome.desktop.interface color-scheme prefer-dark
		printf "Switched To Dark Theme ";
	elif [[ "$1" == 'light' ]]; then
		LIGHT_THEME="Adwaita";
		gsettings set org.gnome.desktop.interface gtk-theme $LIGHT_THEME
		gsettings set org.gnome.desktop.interface color-scheme prefer-light
		printf "Switched To Light Theme ";
	fi
	printf "Successfully\n";
	return 0;
}

spotify_fix()
{
	rm -rf "$HOME/.var/app/com.spotify.Client"
	gnome-terminal -- bash -c flatpak override --user --nosocket=wayland com.spotify.Client
	gnome-terminal -- bash -c "flatpak run com.spotify.Client"
	return 0;
}

update_favourites()
{
	declare -a APPLICATIONS;

	printf "No Args Given ! Using default settings"
	APPLICATIONS=( org.mozilla.firefox com.spotify.Client com.visualstudio.code)  # Applications That will be Updated
	flatpak update "${APPLICATIONS[@]}"  -y ;
}

default_settings()
{
	brightness
	bluetooth_mangler
	resolution
	update_favourites
}

main()
{
	printf "13Toolbox: "
	if [[ $1 = '-bt' ]]; then
		bluetooth_mangler
	elif [[ $1 = '-t' ]]; then
		theme_switcher $2
	elif [[ $1 = '-u' ]]; then
		update_favourites
	elif [[ $1 = '-r' ]]; then
		display $2
	elif [[ $1 = '-b' ]]; then
		brightness $2
	elif [[ $1 = '-s' ]]; then
		spotify_fix
	elif [[ -z "$1" ]]; then
		default_settings
	fi
}

main "$1" $2
