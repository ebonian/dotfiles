#!/usr/bin/env bash

# Get brightness
get_backlight() {
	brightnessctl -m | cut -d, -f4
}

# Change brightness
change_backlight() {
	current_brightness=$(get_backlight | tr -d '%')
	if [[ "$1" == "5%-" ]]; then
		new_brightness=$((current_brightness - 5))
		if [[ $new_brightness -lt 1 ]]; then
			new_brightness=1
		fi
		brightnessctl set "${new_brightness}%"
	else
		brightnessctl set "$1"
	fi
}

# Execute accordingly
case "$1" in
	"--get")
		get_backlight
		;;
	"--inc")
		change_backlight "+5%"
		;;
	"--dec")
		change_backlight "5%-"
		;;
	*)
		get_backlight
		;;
esac
