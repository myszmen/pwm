#!/bin/bash
# runs the latest VPM

# Check if arguments are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <container_name> <display>"
    echo "Output data will be stored in ~/data/OUTPUT/<container_name>"
    exit 1
fi

mkdir -p ~/data/OUTPUT/$1

# Get the DISPLAY argument
DISPLAY_VAR=$2

# RUN DOCKER
docker run --name $1 \
    -it --rm \
    -e DISPLAY=$DISPLAY_VAR \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ~/data:/home/psr/data \
    -v ~/data/OUTPUT/$1:/home/psr/output \
    --net=host \
    memento1315189/vpm2:latest bash

