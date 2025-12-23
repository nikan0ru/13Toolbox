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
		echo -e "$Yellow NO bluethooth device Paired , Exiting! $Black"
		return $ERR;
	fi;
	while [[ i -lt  $paired_devices_count ]] ;
	do
		device=$(echo "${devices_array[i]}" | awk ' {print $2}')
		paired_devices+=("$device");
		bluetoothctl remove "${paired_devices[i]}";
		((i++));
	done
	return 0;
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
	return 0;

}

brightness()
{
	gdbus call --session --dest org.gnome.SettingsDaemon.Power --object-path /org/gnome/SettingsDaemon/Power \
	--method org.freedesktop.DBus.Properties.Set org.gnome.SettingsDaemon.Power.Screen Brightness "<int32 $1>"
	return 0;

}

set_timeswitch()
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

theme_switcher()
{
	read -rp "$Blue set Daytime (00:00)" Day
	read -rp "$Blue set Nightime (00:00)" Night
	jq --arg Day "$Day" '.DayTime |= $Day' userData.json  >> temp.json &&  mv temp.json userData.json
	jq --arg Night "$Night" '.NightTime |= $Night' userData.json  >> temp.json &&  mv temp.json userData.json
	return 0;

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

	printf -e "$Blue No Args Given ! Using default settings $Black"
	APPLICATIONS=( org.mozilla.firefox com.spotify.Client com.visualstudio.code)  # Applications That will be Updated
	flatpak update "${APPLICATIONS[@]}"  -y ;
}

default_settings()
{
	bluetooth_mangler
	display
	update_favourites
}

initial_startup()
{
	read -rp "Preferred Theme ? (light/dark/auto)" Theme
	if [[ "${Theme,,}" == "light" || "${Theme,,}" == "dark" || "${Theme,,}" == "auto" ]]; then
		jq --arg Theme "${Theme,,}" '.preferredSystemTheme |= $Theme' userData.json  \
		>> temp.json &&  mv temp.json userData.json
	# elif [[ "${Response,,}" == "auto" ]]; then
	# 	theme_switcher $Response
		# set_timeswitch
	else
		printf $Red"\nInvalid Argument Try Again"$Black
		initial_startup
	fi

}
main()
{
	GLOBAL_STATE={}
	# FreshStart=$(jq -r ".FreshStart" userData.json )
	# if [[ $FreshStart == "false" ]]; then
	# 	return 0
	# else
		printf $Blue"Welcome to the initial setup, this page will appear only once \n"$Black
		initial_startup

		# jq --arg FreshStart "$FreshStart" '.FreshStart |= false' userData.json  >> temp.json &&  mv temp.json userData.json

	# elif [[ $1 = '-bth' ]]; then
	# 	bluetooth_mangler
	# elif [[ $1 = '-t' ]]; then
	# 	theme_switcher
	# elif [[ $1 = '-u' ]]; then
	# 	update_favourites
	# elif [[ $1 = '-d' ]]; then
	# 	display "$2"
	# elif [[ $1 = '-b' ]]; then
	# 	brightness "$2"
	# elif [[ $1 = '-s' ]]; then
	# 	spotify_fix
	# elif [[ "$1" -eq 0 ]]; then
	# 	default_settings
	# else
	# 	return $ERR;
	# fi
}

main "$1" "$2"
