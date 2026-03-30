extends Levels

const BASE_SPEED      := 280.0
const SPEED_INCREMENT := 20.0
const MAX_SPEED       := 600.0

func get_base_speed() -> float:
	return BASE_SPEED

func get_speed_increment() -> float:
	return SPEED_INCREMENT

func get_max_speed() -> float:
	return MAX_SPEED

func get_speed_up_distance() -> float:
	return 350.0

func get_camera_lead_x() -> float:
	return 140.0

func get_camera_lerp_x() -> float:
	return 9.0
