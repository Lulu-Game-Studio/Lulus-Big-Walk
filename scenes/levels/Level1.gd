extends "res://scenes/levels/levels.gd"

const BASE_SPEED := 220.0 # Base movement speed of Lulu
const SPEED_INCREMENT := 15.0 # Speed added when player speeds up
const MAX_SPEED := 520.0 # Maximum speed limit

# Returns the initial base speed
func get_base_speed() -> float:
	return BASE_SPEED
# Returns how much speed increases per increment
func get_speed_increment() -> float:
	return SPEED_INCREMENT
# Returns the maximum allowed speed
func get_max_speed() -> float:
	return MAX_SPEED
func get_speed_up_distance() -> float:
	return 500.0
# Horizontal offest for the camera to look ahead of the player
func get_camera_lead_x() -> float:
	return 120.0
	# Lerp factor for camera movement on the X axis
func get_camera_lerp_x() -> float:
	return 8.0
