# v0.3

This is shell script that automates some repetitive setup for ubuntu computers.

## Usage

Run the script with no arguments to run default the settings

### Default Settings will run with the following arguments ```-bt -u -b -r```

### -bt: will remove all paired bluetooth devices.

### -r <value> will set the display resolution, if no value is provided the default is ```2560x1440```.

### -u will update the apps specified in ```update_favourites``` if the apps aren't installed then the update will fail. You can find app Identifiers in ```app_list```

### -s Will attempt to fix spotify not running.

### -b <value> will set the brightness level. Accepts Integers only.

### -t (light/dark) will set the system theme.

### Add as an Alias

### in Bash

```bash
	echo "alias 13Toolbox='bash $HOME/13Toolbox/script.sh'" >> ~/.bashrc
source ~/.bashrc
```

### in zsh

```bash
	echo "alias 13Toolbox='bash $HOME/13Toolbox/script.sh'" >> ~/.zshrc
source ~/.zshrc
```


### To run script on startup run copy ```script.sh.desktop``` to ```$HOME/.config/autostart```
```bash
cp $HOME/13Toolbox/script.sh.desktop $HOME/.config/autostart;```.
