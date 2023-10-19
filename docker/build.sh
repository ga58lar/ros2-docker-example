#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd $SCRIPT_DIR/.. && git clone -b main https://github.com/PRBonn/kiss-icp.git

docker build -f $SCRIPT_DIR/../Dockerfile -t ros2-docker-example:latest $SCRIPT_DIR/..