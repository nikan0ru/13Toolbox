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


Black='\033[0;30m'
Red='\033[0;31m'
Green='\033[0;32m'
Yellow='\033[0;33m'
Blue='\033[0;34m'
Purple='\033[0;35m'
Cyan='\033[0;36m'
White='\033[0;37m'

bluetooth_mangler()
{
	declare -i i=0;
	declare -i paired_devices_count;
	declare -a paired_devices;
	declare -a devices_array;

	printf "Removing Bluetooth Devices\n"
	devices=$( bluetoothctl paired-devices )
	paired_devices_count=$(echo "$devices" | grep -c "Device" )
	readarray -t devices_array <<< "$devices"
	if [[ $paired_devices_count -eq 0 ]]; then
		echo -e "$Yellow NO bluethooth device Paired , Exiting! $Black"
		return;
	fi;
	while [[ i -lt  $paired_devices_count ]] ;
	do
		device=$(echo "${devices_array[i]}" | awk ' {print $2}')
		paired_devices+=("$device");
		bluetoothctl remove "${paired_devices[i]}";
		((i++));
	done
	printf "\nDone :)\n"
}

display()
{
	if [[ $1 -eq 0 ]]; then
		RESOLUTION=2560x1440
	else
		RESOLUTION=$1
	fi
	ICON="Win10Sur"
	xrandr -s "$RESOLUTION";
	gsettings set org.gnome.desktop.interface icon-theme "$ICON";
	echo -e "$Green Changed Resolution Successfully $Black";

}

brightness()
{
	gdbus call --session --dest org.gnome.SettingsDaemon.Power --object-path /org/gnome/SettingsDaemon/Power \
	--method org.freedesktop.DBus.Properties.Set org.gnome.SettingsDaemon.Power.Screen Brightness "<int32 $1>"
}

theme_switcher()
{
	night_time="20:15"
	day_time="07:00"
	current_time=$(date +"%H:%M")
	if [[ "$current_time" > "$night_time" || "$current_time" < "$day_time" ]]; then
		darkmode
	elif [[ "$current_time" > "$day_time"  && "$current_time" < "$night_time" ]]; then
		lightmode
	fi
}
lightmode()
{
	LIGHT_THEME="Adwaita";
	echo "Setting Light Theme..."
	gsettings set org.gnome.desktop.interface gtk-theme $LIGHT_THEME
	gsettings set org.gnome.desktop.interface color-scheme prefer-light
}
darkmode()
{
	DARK_THEME="Adwaita";
	echo "Setting Dark Theme..."
	gsettings set org.gnome.desktop.interface gtk-theme $DARK_THEME
	gsettings set org.gnome.desktop.interface color-scheme prefer-dark
}

spotify_fix()
{
	rm -rf "$HOME/.var/app/com.spotify.Client"
	flatpak override --user --nosocket=wayland com.spotify.Client
	flatpak run com.spotify.Client
	echo "eyyyy"
}

update_favourites()
{
	declare -a APPLICATIONS;

	echo -e "$Blue No Args Given ! Using default settings $Black"
	APPLICATIONS=( org.mozilla.firefox com.spotify.Client com.visualstudio.code)  # Applications That will be Updated
	flatpak update "${APPLICATIONS[@]}"  -y ;
}

default_settings()
{
	bluetooth_mangler
	display
	update_favourites
}
main()
{
	if [[ $1 = '-bth' ]]; then
		bluetooth_mangler
	elif [[ $1 = '-t' ]]; then
		theme_switcher
	elif [[ $1 = '-u' ]]; then
		update_favourites
	elif [[ $1 = '-d' ]]; then
		display $2
	elif [[ $1 = '-b' ]]; then
		brightness "$2"
	elif [[ $1 = '-s' ]]; then
		spotify_fix
	elif [[ -z "$1" ]]; then
		default_settings
	else
		return 1
	fi
}

main "$1" "$2"
