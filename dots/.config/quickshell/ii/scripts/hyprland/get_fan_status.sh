#!/bin/bash
# Read status AND maintain fan speed in one call
echo "2312" | sudo -S /home/gmh/.config/quickshell/ii/scripts/hyprland/fan_control.py maintain 2>/dev/null
echo "2312" | sudo -S /home/gmh/.config/quickshell/ii/scripts/hyprland/fan_control.py status 2>/dev/null
