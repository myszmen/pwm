#!/bin/bash

docker run -it --rm \
	-e DISPLAY=:99 \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-v /home/aszary/data:/home/psr/data \
	--net=host \
	vpm:latest /bin/bash

# $DISPLAY for local or :99 for vnc
# you can change  $(pwd)/example_data:/home/psr/data to /path/to/your/data:/home/psr/data
