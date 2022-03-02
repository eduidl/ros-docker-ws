FROM nvidia/cudagl:11.4.2-devel-ubuntu20.04

ENV DEBIAN_FRONTEND noninteractive
ENV ROS_DISTRO noetic

RUN apt-get update -q && apt-get upgrade -yq

RUN apt-get install -yq --no-install-recommends \
    ccache \
    curl \
    locales-all \
    software-properties-common \
    ssh \
    tig \
    wget

RUN add-apt-repository -y ppa:fish-shell/release-3 \
    && add-apt-repository -y ppa:neovim-ppa/stable

RUN  echo "deb http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros-latest.list \
    && (curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -)

RUN apt-get update -q

RUN apt-get install -yq --no-install-recommends \
    fish \
    git \
    neovim \
    ros-${ROS_DISTRO}-desktop-full \
    python3-catkin-tools \
    python3-rosdep \
    python3-vcstool

RUN rosdep init

ARG UID=1000
ARG GID=${UID}

ENV USERNAME devel
ENV HOME /home/$USERNAME

RUN groupadd -g $GID $USERNAME && \
    useradd -m -s /usr/bin/bash -u $UID -g $GID -G sudo $USERNAME && \
    echo "$USERNAME:$USERNAME" | chpasswd

USER $USERNAME
WORKDIR $HOME

RUN rosdep update

COPY ros_entrypoint.sh /ros_entrypoint.sh

ENV DOCKER_MACHINE_NAME noetic

RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> $HOME/.bashrc && \
    echo "source /opt/ros/${ROS_DISTRO}/share/rosbash/rosbash" >> $HOME/.bashrc && \
    echo "source ~/catkin_ws/devel/setup.bash" >> $HOME/.bashrc

CMD [ "/usr/bin/fish" ]
