#!/bin/bash

# Check if a port number is provided
if [ -z "$1" ]; then
	  echo "Usage: $0 <port-number e.g. 5900>"
	    exit 1
fi

PORT=$1

# Start Xvfb in the background
Xvfb :99 -screen 0 1024x768x24 > /home/psr/log/xvfb.log 2>&1 &

sleep 2

# Start x11vnc in the background with the specified port
x11vnc -display :99 -forever -nopw -rfbport $PORT > /home/psr/log/x11vnc.log 2>&1 &

