extends "res://scenes/levels/levels.gd"

const BASE_SPEED := 250.0
const SPEED_INCREMENT := 18.0
const MAX_SPEED := 560.0

func get_base_speed() -> float:
	return BASE_SPEED
	
func get_speed_increment() -> float:
	return SPEED_INCREMENT

func get_max_speed() -> float:
	return MAX_SPEED

func get_speed_up_distance() -> float:
	return 400.0

func get_camera_lead_x() -> float:
	return 120.0

func get_camera_lerp_x() -> float:
	return 8.0
