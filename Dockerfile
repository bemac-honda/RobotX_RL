# A Docker image to provide HTML5 VNC interface to access Ubuntu LXDE + ROS
FROM tiryoh/ros-desktop-vnc:kinetic

# For RobotX Challenge by Reinforcement Learning
# 1. Update Gazebo7 and Install basic python3 packages and virtualenv
RUN sudo apt-get purge -y ros-kinetic-gazebo* \
    && sudo apt-get purge --auto-remove -y gazebo7 \
    && sudo sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list' \
    && wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add - \
    && sudo apt-get update \
    && sudo apt-get install -y \
    ros-kinetic-desktop-full \
    python-catkin-tools \
    python3-dev \
    python3-numpy \
    python-pip \
    libbullet-dev \
    ros-kinetic-hector-gazebo-plugins \
    ros-kinetic-rqt-multiplot \
    gazebo7 \
    ros-kinetic-ros-control \
    ros-kinetic-ros-controllers \
    && pip install --upgrade pip \
    && sudo pip install virtualenv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. Create a Python3 virtual environment inside your Python2 environment
RUN mkdir -p /home/ubuntu/python3_ws/src \
    && cd /home/ubuntu/python3_ws \
    && virtualenv py3venv --python=python3

# 3. Install the Python3 required libraries and its dependencies
RUN . /home/ubuntu/python3_ws/py3venv/bin/activate \
    && cd /home/ubuntu/python3_ws/src \
    && git clone https://github.com/openai/baselines.git \
    && cd /home/ubuntu/python3_ws/src/baselines \
    && pip install tensorflow==1.15rc2 \
    && pip install -e . \
    && pip install gym

# 4. Install the ROS packages required by ROS code and compile
RUN . /home/ubuntu/python3_ws/py3venv/bin/activate \
    && cd /home/ubuntu/python3_ws/src/ \
    && git clone -b melodic-devel https://github.com/ros/geometry \
    && git clone -b melodic-devel https://github.com/ros/geometry2 \
    && pip install pyaml \
    && pip install rospkg \
    && pip install empy \
    && pip3 install keras==2.2.4
COPY CMakeLists.txt /home/ubuntu/python3_ws/src/geometry/geometry/CMakeLists.txt
RUN . /home/ubuntu/python3_ws/py3venv/bin/activate \
    && cd /home/ubuntu/python3_ws/ \
    && /bin/bash -c "source /opt/ros/kinetic/setup.bash; \
    catkin_make -DPYTHON_EXECUTABLE:FILEPATH=/home/ubuntu/python3_ws/py3venv/bin/python; \
    source /home/ubuntu/python3_ws/devel/setup.bash"

# 5. Set the simulation environment
COPY simulation_ws/ /home/ubuntu/simulation_ws
RUN cd /home/ubuntu/simulation_ws \
    && rm -rf build devel \
    && /bin/bash -c "source /opt/ros/kinetic/setup.bash; \
    rosdep install -r --from-path src --ignore-src -y; \
    catkin_make"

# 6. Set DeepQlearning
COPY robotx_ws/ /home/ubuntu/robotx_ws
RUN . /home/ubuntu/python3_ws/py3venv/bin/activate \
    && /bin/bash -c "source /home/ubuntu/python3_ws/devel/setup.bash" \
    && cd /home/ubuntu/robotx_ws \
    && rm -rf build devel \
    && /bin/bash -c "source /opt/ros/kinetic/setup.bash; \
    rosdep install -r --from-path src --ignore-src -y; \
    catkin_make -DPYTHON_EXECUTABLE:FILEPATH=/home/ubuntu/python3_ws/py3venv/bin/python"
