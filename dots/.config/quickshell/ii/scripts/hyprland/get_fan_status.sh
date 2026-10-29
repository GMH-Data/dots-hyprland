#!/bin/bash
# Read status AND maintain fan speed in one call
sudo -n /usr/local/lib/fan-control/fan_control.py maintain 2>/dev/null
sudo -n /usr/local/lib/fan-control/fan_control.py status 2>/dev/null
