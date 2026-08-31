#!/bin/bash

# Close existing dashboard windows to prevent duplicates
hyprctl clients -j | jq -r '.[] | select(.class == "btop-home" or .class == "nvtop-home" or .class == "lazydocker-home") | .address' | while read -r addr; do
    hyprctl dispatch closewindow "address:$addr"
done

sleep 0.2

# 1. Launch btop (will occupy left side)
kitty --class btop-home --title 'btop ~' -e btop &
sleep 0.3

# 2. Launch nvtop (will split btop vertically, taking right side)
kitty --class nvtop-home --title 'nvtop ~' -e nvtop &
sleep 0.3

# Ensure nvtop is focused so the next split happens on it
hyprctl dispatch focuswindow "class:nvtop-home"
sleep 0.1

# 3. Launch lazydocker (will split nvtop horizontally, taking bottom right)
kitty --class lazydocker-home --title 'lazydocker ~' -e lazydocker &
