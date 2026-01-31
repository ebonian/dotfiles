#!/usr/bin/env bash
# Cycle battery charge limit between 60% / 80% / 100%
# 60% = Maximum battery care | 80% = Balanced care | 100% = Full charge
# Uses asusctl for ASUS ROG laptops (communicates with asusd daemon)

SYSFS_PATH="/sys/class/power_supply/BAT1/charge_control_end_threshold"

# Check if asusctl is available
if ! command -v asusctl &>/dev/null; then
    notify-send "Battery Limit" "Error: asusctl not found" -u critical
    echo "Error: asusctl not found"
    exit 1
fi

# Check if battery threshold file exists
if [ ! -f "$SYSFS_PATH" ]; then
    notify-send "Battery Limit" "Error: Battery threshold control not found" -u critical
    echo "Error: Battery threshold control not found at $SYSFS_PATH"
    exit 1
fi

# Read current limit
CURRENT_LIMIT=$(cat "$SYSFS_PATH" 2>/dev/null)

if [ -z "$CURRENT_LIMIT" ]; then
    notify-send "Battery Limit" "Error: Cannot read battery threshold" -u critical
    echo "Error: Cannot read battery threshold"
    exit 1
fi

echo "Current charge limit: $CURRENT_LIMIT%"

# Cycle through 60% -> 80% -> 100% -> 60%
if [ "$CURRENT_LIMIT" -le 60 ]; then
    # Switch to 80% (balanced care mode)
    if asusctl -c 80 2>/dev/null; then
        notify-send "Battery Limit" "🔋 Set to 80% (Balanced Care)" -u normal -t 3000
        echo "Battery charge limit set to 80%"
    else
        notify-send "Battery Limit" "Error: Failed to set charge limit" -u critical
        echo "Error: Failed to set charge limit"
        exit 1
    fi
elif [ "$CURRENT_LIMIT" -le 85 ]; then
    # Switch to 100% (full charge mode)
    if asusctl -c 100 2>/dev/null; then
        notify-send "Battery Limit" "⚡ Set to 100% (Full Charge)" -u normal -t 3000
        echo "Battery charge limit set to 100%"
    else
        notify-send "Battery Limit" "Error: Failed to set charge limit" -u critical
        echo "Error: Failed to set charge limit"
        exit 1
    fi
else
    # Switch to 60% (maximum care mode)
    if asusctl -c 60 2>/dev/null; then
        notify-send "Battery Limit" "🌿 Set to 60% (Maximum Care)" -u normal -t 3000
        echo "Battery charge limit set to 60%"
    else
        notify-send "Battery Limit" "Error: Failed to set charge limit" -u critical
        echo "Error: Failed to set charge limit"
        exit 1
    fi
fi
