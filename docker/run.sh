#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
xhost +
docker run --rm -it \
    --network=host \
    --privileged \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix/:/tmp/.X11-unix/ \
    -v /dev/shm:/dev/shm \
    -v $SCRIPT_DIR/../data:/data \
    -e ROS_DOMAIN_ID=77 \
    ros2-docker-example:latest \
    bash -c "ros2 launch kiss_icp odometry.launch.py bagfile:=/data/ topic:=/luminar_front_points"
xhost -