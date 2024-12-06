#!/bin/bash
docker run -it --rm \
	-e DISPLAY=$DISPLAY \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-v $(pwd)/example_data:/home/psr/data \
	--net=host \
	vpm:latest bash

# you can change  $(pwd)/example_data:/home/psr/data to /path/to/your/data:/home/psr/data
