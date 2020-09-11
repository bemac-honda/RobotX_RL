# A Docker image to provide HTML5 VNC interface to access Ubuntu LXDE + ROS
FROM tiryoh/ros-desktop-vnc:kinetic

# For RobotX Challenge by Reinforcement Learning
# 1. Update Gazebo7 and Install basic python3 packages and virtualenv
RUN sudo apt-get update \
    && sudo apt-get install -y \
    ros-kinetic-desktop-full \
    python-catkin-tools \
    python3-dev \
    python3-numpy \
    python-pip \
    libbullet-dev \
    ros-kinetic-rqt-multiplot \
    && pip install --upgrade pip \
    && sudo pip install virtualenv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. Create a Python3 virtual environment inside your Python2 environment
RUN mkdir -p ~/python3_ws/src \
    && cd ~/python3_ws \
    && virtualenv py3venv --python=python3 \

# 3. Install the Python3 required libraries and its dependencies
RUN source ~/python3_ws/py3venv/bin/activate \
    && source ~/python3_ws/devel/setup.bash \
    && cd ~/python3_ws/src \
    && git clone https://github.com/openai/baselines.git \
    && cd ~/python3_ws/src/baselines \
    && pip install -y \
    tensorflow==1.15rc2 \
    gym \
    && pip install -y -e .
