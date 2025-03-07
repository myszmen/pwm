#!/bin/bash

#!/bin/bash

# Check if an argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <DISPLAY_VALUE e.g :99 or local>"
    echo "Example: $0 :99"
    exit 1
fi

DISPLAY_VALUE=$1

docker run -it --rm \
        -e DISPLAY=$DISPLAY_VALUE \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v /home/aszary/data:/home/psr/data \
        --net=host \
        vpm:latest /bin/bash

