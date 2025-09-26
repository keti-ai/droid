from droid.controllers.oculus_controller import VRPolicy
from droid.robot_env import RobotEnv
from droid.user_interface.data_collector import DataCollecter
from droid.user_interface.gui import RobotGUI
import argparse
import threading
import time

parser = argparse.ArgumentParser(description='Process a boolean argument for right_controller.')

# Adding the right_controller argument
parser.add_argument('--left_controller', action='store_true', help='Use left oculus controller')
parser.add_argument('--right_controller', action='store_true', help='Use right oculus controller')


args = parser.parse_args()

# Make the robot env
print("DEBUG: Creating RobotEnv...")
env = RobotEnv()
print("DEBUG: RobotEnv created successfully!")

# VRPolicy를 먼저 생성하고 별도 스레드에서 실행
print("DEBUG: Creating VRPolicy...")
if args.left_controller:
    controller = VRPolicy(right_controller=False)
    right_controller = False
    print("DEBUG: VRPolicy created with left_controller=True")
else:
    controller = VRPolicy(right_controller=True)
    right_controller = True
    print("DEBUG: VRPolicy created with right_controller=True")
print("DEBUG: VRPolicy created successfully!")

print("DEBUG: Starting VRPolicy in separate thread...")
# VRPolicy를 별도 스레드에서 실행
controller_thread = threading.Thread(target=controller._update_internal_state)
controller_thread.daemon = True
controller_thread.start()

# DataCollecter 생성
print("DEBUG: Creating DataCollecter...")
data_collector = DataCollecter(env=env, controller=controller)
print("DEBUG: DataCollecter created successfully!")

# GUI 생성 및 실행
print("DEBUG: Creating RobotGUI...")
user_interface = RobotGUI(robot=data_collector, right_controller=right_controller)
print("DEBUG: RobotGUI created successfully!")

print("DEBUG: GUI should now be visible on screen!")
print("DEBUG: GUI is now running. Press Ctrl+C to exit.")




