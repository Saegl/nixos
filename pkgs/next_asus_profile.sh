#!/usr/bin/env bash

# Switch to the next profile
asusctl profile -n

# Get the current profile
CURRENT_PROFILE=$(asusctl profile -p)

# Send a notification
notify-send "ASUS Profile Changed" "$CURRENT_PROFILE"
