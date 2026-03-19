extends Node

var current_level: int = 1
var levels_unlocked: int = 1  # Player starts in level 1

const LEVELS = {
	1: "res://scenes/levels/Level1_Park.tscn",
	2: "res://scenes/levels/Level2_City.tscn",
	3: "res://scenes/levels/Level3_Forest.tscn",
}

func go_to_level(level_number: int) -> void:
	current_level = level_number
	get_tree().change_scene_to_file(LEVELS[level_number])

func complete_level() -> void:
	if current_level >= levels_unlocked:
		levels_unlocked = current_level + 1
	go_to_next_level()

func go_to_next_level() -> void:
	var next = current_level + 1
	if LEVELS.has(next):
		go_to_level(next)
	else:
		get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

func go_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
