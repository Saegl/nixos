#!/usr/bin/env bash

# Switch to the next profile
asusctl profile next

# Get the current profile
CURRENT_PROFILE=$(asusctl profile get)

# Send a notification
notify-send "ASUS Profile Changed" "$CURRENT_PROFILE"
