#!/usr/bin/env bash

# Get keyboard brightness
get_kbd_backlight() {
	echo $(brightnessctl -d 'asus::kbd_backlight' -m | cut -d, -f4)
}

# Change brightness
change_kbd_backlight() {
	brightnessctl -d asus::kbd_backlight set "$1"
}

# Execute accordingly
case "$1" in
	"--get")
		get_kbd_backlight
		;;
	"--inc")
		change_kbd_backlight "+30%"
		;;
	"--dec")
		change_kbd_backlight "30%-"
		;;
	*)
		get_kbd_backlight
		;;
esac