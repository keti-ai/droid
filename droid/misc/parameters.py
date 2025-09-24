import os
from cv2 import aruco

# Robot Params #
nuc_ip = "172.16.0.5"
robot_ip = "172.16.0.2"
laptop_ip = "172.16.0.1"
sudo_password = os.getenv("DROID_SUDO_PASSWORD", "REPLACED")
robot_type = "fr3"  # 'panda' or 'fr3'
robot_serial_number = "309969-2543204"

# Camera ID's #
hand_camera_id = "19133851"
varied_camera_1_id = "33763137"
varied_camera_2_id = "31194385"

# Charuco Board Params #
CHARUCOBOARD_ROWCOUNT = 9
CHARUCOBOARD_COLCOUNT = 14
CHARUCOBOARD_CHECKER_SIZE = 0.020
CHARUCOBOARD_MARKER_SIZE = 0.016
ARUCO_DICT = aruco.getPredefinedDictionary(aruco.DICT_5X5_100)

# Ubuntu Pro Token (RT PATCH) #
ubuntu_pro_token = os.getenv("DROID_UBUNTU_PRO_TOKEN", "REPLACED")

# Code Version [DONT CHANGE] #
droid_version = "1.3"

