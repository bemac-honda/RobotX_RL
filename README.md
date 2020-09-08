# RobotX_RL

A Docker image to provide HTML5 VNC interface to access Ubuntu LXDE + ROS including RobotX Challenge simulation demo.

# Quick Start

1. Run the docker container and access with port `6080`.
   Change the `shm-size` value depending on the situation.
`docker run -p 6080:80 --shm-size=512m bemac-honda/RobotX_RL:latest`
2. Browse http://127.0.0.1:6080.
3. Open your terminal in VNC viewer.
   MENU button in lower left -> System Tools -> LXTerminal (or Terminator)
4. Launch RobotX Challenge simulator as follows.
   To launch the simulation environment
   `roslaunch robotx_gazebo sandisland_with_buoys.launch`
   To

