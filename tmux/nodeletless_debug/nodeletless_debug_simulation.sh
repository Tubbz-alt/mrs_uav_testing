#!/bin/bash

SESSION_NAME=uav1
UAV_NAME=$SESSION_NAME

# following commands will be executed first, in each window
pre_input="export UAV_NAME=$UAV_NAME; export ATHAME_ENABLED=0"

# define commands
# 'name' 'command'
input=(
  'Roscore' 'roscore
'
  'Gazebo' "waitForRos; roslaunch mrs_odometry gazebo_grass_plane.launch gui:=false
"
  'Spawn' "waitForSimulation; spawn 1 --run --delete --enable-rangefinder --enable-ground-truth --file ~/mrs_workspace/src/uav_core/ros_packages/mrs_odometry/config/init_pose/init_pose.csv
"
  'uav_manager' "waitForOdometry; roslaunch mrs_testing mrs_uav_manager.launch
"
  'mrs_odometry' "waitForOdometry; roslaunch mrs_testing mrs_odometry.launch
"
  'control_manager' "waitForOdometry; roslaunch mrs_testing mrs_control_manager.launch
"
  'gain_manager' "waitForOdometry; roslaunch mrs_testing mrs_gain_manager.launch
"
  'constraint_manager' "waitForOdometry; roslaunch mrs_testing mrs_constraint_manager.launch
"
  "PrepareUAV" "waitForControl; rosservice call /$UAV_NAME/mavros/cmd/arming 1; rosservice call /$UAV_NAME/control_manager/motors 1; rosservice call /$UAV_NAME/mavros/set_mode 0 offboard; rosservice call /$UAV_NAME/uav_manager/takeoff;
"
  'ChangeEstimator' "rosservice call /$UAV_NAME/odometry/change_estimator_type_string GPS"
  'GoTo' "rosservice call /$UAV_NAME/control_manager/goto \"goal: [0.0, 0.0, 3.0, 0.0]\""
  'GoToRelative' "rosservice call /$UAV_NAME/control_manager/goto_relative \"goal: [0.0, 0.0, 0.0, 0.0]\""
  'RVIZ' "waitForOdometry; nice -n 10 rosrun rviz rviz -d ~/mrs_workspace/src/uav_core/ros_packages/mrs_odometry/rviz/uav1_odometry_single.rviz
  "
)

if [ -z ${TMUX} ];
then
  TMUX= tmux new-session -s $SESSION_NAME -d
  echo "Starting new session."
else
  SESSION_NAME="$(tmux display-message -p '#S')"
fi

# create arrays of names and commands
for ((i=0; i < ${#input[*]}; i++));
do
  ((i%2==0)) && names[$i/2]="${input[$i]}" 
	((i%2==1)) && cmds[$i/2]="${input[$i]}"
done

# run tmux windows
for ((i=0; i < ${#names[*]}; i++));
do
	tmux new-window -t $SESSION_NAME:$(($i+10)) -n "${names[$i]}"
done

sleep 4

# send commands
for ((i=0; i < ${#cmds[*]}; i++));
do
	tmux send-keys -t $SESSION_NAME:$(($i+10)) "${pre_input};
${cmds[$i]}"
done

sleep 4

tmux select-window -t $SESSION_NAME:0
tmux -2 attach-session -t $SESSION_NAME

clear
