#!/usr/bin/env bash

# Get the window list as JSON
windows=$(niri msg -j windows)

# Use fuzzel to pick a window (title + app_id for better uniqueness)
selection=$(echo "$windows" | jq -r '.[] | "\(.id) \(.title) (\(.app_id))"' | fuzzel --dmenu)

# Extract the ID from the selected entry
win_id=$(echo "$selection" | awk '{print $1}')

# Focus the selected window
if [[ -n "$win_id" ]]; then
    niri msg action focus-window --id "$win_id"
fi
