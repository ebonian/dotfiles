#!/usr/bin/env bash

# Get brightness
get_backlight() {
	echo $(brightnessctl -m | cut -d, -f4)
}

# Change brightness
change_backlight() {
	brightnessctl set "$1"
}

# Execute accordingly
case "$1" in
	"--get")
		get_backlight
		;;
	"--inc")
		change_backlight "+10%"
		;;
	"--dec")
		change_backlight "10%-"
		;;
	*)
		get_backlight
		;;
esac