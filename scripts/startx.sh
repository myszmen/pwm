#!/bin/bash

# Start Xvfb in the background
Xvfb :99 -screen 0 1024x768x24 > /home/psr/log/xvfb.log 2>&1 &

sleep 2

# Start x11vnc in the background
x11vnc -display :99 -forever -nopw -rfbport 5900 > /home/psr/log/x11vnc.log 2>&1 &

