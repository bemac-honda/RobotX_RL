# A Docker image to provide HTML5 VNC interface to access Ubuntu LXDE + ROS
FROM tiryoh/ros-desktop-vnc:kinetic

# For RobotX Challenge by Reinforcement Learning
# 1. Install basic python3 packages and virtualenv
RUN sudo apt-get update \
    && sudo apt-get install -y \
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

# 2. Create and activate a Python3 virtual environment inside your Python2 environment
RUN mkdir -p ~/python3_ws/src \
    && cd ~/python3_ws \
    && virtualenv py3venv --python=python3 \
    && source ~/python3_ws/py3venv/bin/activate

# 3. Install the Python3 required libraries and its dependencies
RUN cd ~/python3_ws/src \
    && git clone https://github.com/openai/baselines.git \
    && cd ~/python3_ws/src/baselines \
    && pip install -y \
    tensorflow==1.15rc2 \
    gym \
    -e .

# 4. Install the ROS packages required by ROS code and compile
RUN cd ~/python3_ws/src/ \
    && git clone -b melodic-devel https://github.com/ros/geometry \
    && git clone -b melodic-devel https://github.com/ros/geometry2 \
    && pip install \
    pyaml \
    rospkg \
    empy \
    && catkin_make -DPYTHON_EXECUTABLE:FILEPATH=~/python3_ws/py3venv/bin/python \
    && source ~/python3_ws/devel/setup.bash

# 5. Create workspace
ENV User ubuntu
COPY WRobot_simulation/ /home/ubuntu/WRobot_simulation
RUN mkdir -p /home/ubuntu/WRobot/src
RUN cd /home/ubuntu/WRobot && \
    /bin/bash  -c "source /opt/ros/melodic/setup.bash; catkin_make"
RUN sudo cp /home/ubuntu/WRobot_simulation/ws/src/ /home/ubuntu/WRobot/ -r
RUN cd /home/ubuntu/WRobot && \
    /bin/bash  -c "source /opt/ros/melodic/setup.bash; catkin_make"
RUN sudo sh -c 'echo "source /home/ubuntu/WRobot/devel/setup.bash" >> ~/.bashrc'