#!/usr/bin/env bash

# Get the window list as JSON
windows=$(niri msg -j windows)

# Use fuzzel to pick a window with workspace info
selection=$(echo "$windows" | jq -r '.[] | "[\(.workspace_id)] \(.app_id) \(.title) (\(.id))"' | fuzzel --dmenu)

# Extract the ID from the selected entry (the number inside parentheses at the end)
win_id=$(echo "$selection" | grep -oP '\(\K[0-9]+(?=\))')

# Focus the selected window
if [[ -n "$win_id" ]]; then
    niri msg action focus-window --id "$win_id"
fi
