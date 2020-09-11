# A Docker image to provide HTML5 VNC interface to access Ubuntu LXDE + ROS
FROM tiryoh/ros-desktop-vnc:kinetic

# For RobotX Challenge by Reinforcement Learning
# 1. Update Gazebo7 and Install basic python3 packages and virtualenv
RUN sudo sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list' \
    && wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add - \
    && sudo apt-get update \
    && sudo apt-get purge ros-kinetic-* \
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
    -e .

# 4. Install the ROS packages required by ROS code and compile
RUN source ~/python3_ws/py3venv/bin/activate \
    && source ~/python3_ws/devel/setup.bash \
    && cd ~/python3_ws/src/ \
    && git clone -b melodic-devel https://github.com/ros/geometry \
# geometry's CMakeLists.txt
    && git clone -b melodic-devel https://github.com/ros/geometry2 \
    && pip install \
    pyaml \
    rospkg \
    empy \
    && pip3 install keras==2.2.4 \
    && catkin_make -DPYTHON_EXECUTABLE:FILEPATH=~/python3_ws/py3venv/bin/python \
    && source ~/python3_ws/devel/setup.bash

# 5. Launch the simulation environment
COPY simulation_ws/ ~/simulation_ws
RUN cd ~/simulation_ws \
    && rosdep install -r --from-path src --ignore-src \
    && catkin_make \
    && source ~/simulation_ws/devel/setup.bash \
    && rospack profile \
    && roslaunch robotx_gazebo sandisland_with_buoys.launch

# 6. Start DeepQlearning
COPY robotx_ws/ ~/robotx_ws
RUN source ~/python3_ws/py3venv/bin/activate \
    && source ~/python3_ws/devel/setup.bash \
    && cd ~/robotx_ws \
    && rosdep install -r --from-path src --ignore-src \
    && catkin_make -DPYTHON_EXECUTABLE:FILEPATH=~/python3_ws/py3venv/bin/python \
    && source ~/robotx_ws/devel/setup.bash \
