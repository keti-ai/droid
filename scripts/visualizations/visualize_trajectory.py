from droid.trajectory_utils.misc import visualize_trajectory

trajectory_folderpath = "/home/syhlab/workspace/droid/data/success/2025-10-24/Fri_Oct_24_08:53:49_2025"

camera_kwargs = dict(
    hand_camera=dict(image=True, resolution=(0, 0)),
    varied_camera=dict(image=True, resolution=(0, 0)),
)

h5_filepath = trajectory_folderpath + "/trajectory.h5"
recording_folderpath = trajectory_folderpath + "/recordings/SVO"
visualize_trajectory(filepath=h5_filepath, recording_folderpath=recording_folderpath, camera_kwargs=camera_kwargs)
