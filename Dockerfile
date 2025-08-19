FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Sao_Paulo

RUN apt update -y && apt upgrade -y && apt install -y curl wget python3-pip python3-dev lsb-release

RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' && \
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - && \
    apt update -y && \
    apt install -y ros-noetic-desktop-full && \
    echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc && \
    sh \
    -c 'echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" \
        > /etc/apt/sources.list.d/ros-latest.list' && \
    wget http://packages.ros.org/ros.key -O - | apt-key add - && \
    apt update -y && \
    apt install -y python3-catkin-tools python3-rosdep python3-rosinstall python3-rosinstall-generator \
    python3-wstool build-essential python3-rosdep ros-noetic-catkin ros-noetic-rviz \
    ros-noetic-robot-localization ros-noetic-husky-* && \
    curl -sSL http://get.gazebosim.org | sh

WORKDIR /ws/src

COPY . .

WORKDIR /ws

RUN . /opt/ros/noetic/setup.sh && \
    catkin config --extend /opt/ros/noetic && \
    catkin build

RUN sudo rosdep fix-permissions && rosdep init && \
    rosdep update && \
    rosdep install --from-paths src/lar_gazebo --ignore-src -r -y --rosdistro noetic && \
    catkin build

RUN pip3 install torch tensorboard squaternion
