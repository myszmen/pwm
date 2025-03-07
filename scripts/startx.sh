#!/bin/bash

# Check if both port number and DISPLAY value are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <port-number e.g. 5900> <DISPLAY e.g. :99>"
    exit 1
fi

PORT=$1
DISPLAY_VALUE=$2

# Start Xvfb in the background with the specified DISPLAY
Xvfb $DISPLAY_VALUE -screen 0 1024x768x24 > /home/psr/log/xvfb.log 2>&1 &

sleep 2

# Start x11vnc in the background with the specified DISPLAY and port
x11vnc -display $DISPLAY_VALUE -forever -nopw -rfbport $PORT > /home/psr/log/x11vnc.log 2>&1 &

