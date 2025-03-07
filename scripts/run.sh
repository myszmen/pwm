#!/bin/bash
# runs the latest VPM

# Check if arguments are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <container_name> <display>"
    echo "Data will be copied to ~/output/<container_name> every 30 seconds"
    exit 1
fi

mkdir -p ~/output/$1

# Get the DISPLAY argument
DISPLAY_VAR=$2

# copy files from /home/psr/output/ in the background
(
while true; do
    sleep 30
    docker cp $1:/home/psr/output/. ~/output/$1 > /dev/null 2>&1;
done
)&

# Capture the Process ID (PID) of the background job
loop_pid=$!

# RUN DOCKER
docker run --name $1 \
    -it --rm \
    -e DISPLAY=$DISPLAY_VAR \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ~/data:/home/psr/data \
    --net=host \
    memento1315189/vpm2:latest bash


echo "Stopping the background process with PID: $loop_pid"
kill $loop_pid

# Optional: Ensure the process is terminated
wait $loop_pid 2>/dev/null
echo "Background process stopped."

