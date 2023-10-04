ARG ROS_DISTRO=humble
FROM ros:$ROS_DISTRO

ARG DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y -q --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    gnupg2 \
    locales \
    lsb-release \
    python3-pip \
    python3-pytest-cov \
    python3-setuptools \
    git \
    vim \
    ros-$ROS_DISTRO-rviz2 \
&& rm -rf /var/lib/apt/lists/*

# Generate and set locales
RUN locale-gen en_US en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# Set environment variables
ENV TZ=${TZ:-Europe/Berlin}
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV ROS_PYTHON_VERSION=3
ENV RCUTILS_CONSOLE_OUTPUT_FORMAT="[{severity} {time}]: {message}"

# Set workspace
WORKDIR /dev_ws

# Copy KISS-ICP
COPY kiss-icp/ /dev_ws/src/kiss-icp/

# Delete rosdep init list
# This will allow each module dockerfile to run rosdep init itself
RUN rm -f /etc/ros/rosdep/sources.list.d/20-default.list


# Build workspace
RUN bash -c "source /opt/ros/$ROS_DISTRO/setup.bash && \
    rosdep init && \
    rosdep update && \
    rosdep install --from-paths src --ignore-src -r -y"

RUN bash -c "source /opt/ros/$ROS_DISTRO/setup.bash && \
             colcon build"

# Set entrypoint by sourcing overlay workspace
RUN echo '#!/bin/bash\nset -e\n\n# setup ros environment\nsource "/opt/ros/$ROS_DISTRO/setup.bash"\n. /dev_ws/install/local_setup.bash\nexec "$@"' > /ros_entrypoint.sh && \
    chmod +x /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
