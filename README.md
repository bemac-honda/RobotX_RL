# RobotX_RL

A Docker image to provide HTML5 VNC interface to access Ubuntu LXDE + ROS including RobotX Challenge simulation demo.

# Quick Start

1. Run the docker container and access with port `6080`. 

   - Change the `shm-size` value depending on the situation. 
   
      `docker run -p 6080:80 --shm-size=512m honda28/RobotX_RL:latest`

2. Browse http://127.0.0.1:6080.

3. Open two terminals in VNC viewer. 

   - MENU button in lower left -> System Tools -> LXTerminal
   
4. Launch RobotX Challenge simulator as follows.

   - To launch the simulation environment 

      `source ~/simulation_ws/devel/setup.bash` 

      `roslaunch robotx_gazebo sandisland_with_buoys.launch` 

   - To Start the reinforcement learning

      `source ~/python3_ws/py3venv/bin/activate`

      `source ~/robotx_ws/devel/setup.bash`

      `roslaunch wamv_deep_qlearning start_wamv_deepqlearning.launch`

# How to build

   `git clone https://github.com/bemac-honda/RobotX_RL.git`

   `cd RobotX_RL`

   `docker build -t honda28/robotx-dqn:latest`