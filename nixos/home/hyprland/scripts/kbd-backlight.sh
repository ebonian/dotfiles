#!/usr/bin/env bash

# Get keyboard brightness
get_kbd_backlight() {
	brightnessctl -d 'asus::kbd_backlight' -m | cut -d, -f3
}

# Change brightness
set_kbd_backlight() {
	brightnessctl -d asus::kbd_backlight set "$1"
}

# Clamp a value between a minimum and maximum
clamp() {
	local value="$1"
	local min="$2"
	local max="$3"
	if (( value < min )); then
		echo "$min"
	elif (( value > max )); then
		echo "$max"
	else
		echo "$value"
	fi
}

# Increment or decrement brightness
adjust_kbd_backlight() {
	local direction="$1"
	local current=$(get_kbd_backlight)
	local new_value

	case "$direction" in
		"inc")
			new_value=$((current + 1))
			;;
		"dec")
			new_value=$((current - 1))
			;;
	esac

	# Clamp the new value between 0 and 3
	new_value=$(clamp "$new_value" 0 3)
	set_kbd_backlight "$new_value"
}

# Execute accordingly
case "$1" in
	"--get")
		get_kbd_backlight
		;;
	"--inc")
		adjust_kbd_backlight "inc"
		;;
	"--dec")
		adjust_kbd_backlight "dec"
		;;
	*)
		echo "Usage: $0 --get | --inc | --dec"
		;;
esac
