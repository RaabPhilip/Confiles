#!/bin/sh

# 1. Get the JSON of all devices
DEVICES_JSON=$(hyprctl devices -j)

# 2. Extract the device name and its current status
# This jq filter finds the touchpad and returns its name and its 'enabled' status
# We use a single jq call to handle both for speed and reliability
DATA=$(echo "$DEVICES_JSON" | jq -r '.mice[] | select(.name | contains("touchpad")) | "\(.name) \(.enabled)"')

if [ -z "$DATA" ]; then
    echo "Error: Touchpad not found."
    exit 1
fi

# Split the name and status
DEVICE_NAME=$(echo "$DATA" | cut -d' ' -f1)
IS_ENABLED=$(echo "$DATA" | cut -d' ' -f2)

echo "Device Name: $DEVICE_NAME"
echo "Is Enabled: $IS_ENABLED"

# 3. Toggle Logic
# If enabled is true, we set it to false
if [ "$IS_ENABLED" = "true" ]; then
    hyprctl keyword "device[$DEVICE_NAME]:enabled" false
    command -v notify-send >/dev/null && notify-send -u low -t 2000 "Touchpad" "Disabled"
else
    hyprctl keyword "device[$DEVICE_NAME]:enabled" true
    command -v notify-send >/dev/null && notify-send -u low -t 2000 "Touchpad" "Enabled"
fi
