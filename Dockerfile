# A Docker image to provide HTML5 VNC interface to access Ubuntu LXDE + ROS
FROM tiryoh/ros-desktop-vnc:kinetic

# For RobotX Challenge by Reinforcement Learning
# 1. Installing
RUN sudo apt update \
    && sudo apt install -y --no-install-recommends \
    ros-kinetic-robot-pose-ekf \
    ros-kinetic-move-base \
    ros-kinetic-map-server \
    ros-kinetic-dwa-local-planner \
    ros-kinetic-turtlebot3-slam \
    ros-kinetic-gmapping \
    terminator \
    git \
    && apt autoclean -y \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# 2. Create workspace
ENV User ubuntu
COPY WRobot_simulation/ /home/ubuntu/WRobot_simulation
RUN mkdir -p /home/ubuntu/WRobot/src
RUN cd /home/ubuntu/WRobot && \
    /bin/bash  -c "source /opt/ros/kinetic/setup.bash; catkin_make"
RUN sudo cp /home/ubuntu/WRobot_simulation/ws/src/ /home/ubuntu/WRobot/ -r
RUN cd /home/ubuntu/WRobot && \
    /bin/bash  -c "source /opt/ros/kinetic/setup.bash; catkin_make"
RUN sudo sh -c 'echo "source /home/ubuntu/WRobot/devel/setup.bash" >> ~/.bashrc'

# 3. Environmental configuration
RUN chmod +x /home/ubuntu/WRobot/src/robot/map_tf_publisher.py
RUN chmod +x /home/ubuntu/WRobot/src/teleop/key_publisher.py
RUN chmod +x /home/ubuntu/WRobot/src/teleop/keys_to_twist.py