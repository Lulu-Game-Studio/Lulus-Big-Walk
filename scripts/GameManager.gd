extends Node

# Persistent game state
var current_level   : int   = 1
var levels_unlocked : int   = 1

# Last run stats
var last_score    : int   = 0
var last_distance : float = 0.0
var last_bones    : int   = 0

 # Best results
var highscore     : int   = 0
var best_distance : float = 0.0

# Save file path
const SAVE_PATH := "user://lulu_save.cfg"

# Level index
const LEVELS = {
	1: "res://scenes/levels/Level1_Park.tscn",
	2: "res://scenes/levels/Level2_Cave.tscn",
	3: "res://scenes/levels/Level3_Forest.tscn",
}

# Load saved progress when the game starts
func _ready() -> void:
	_load()

# Save / Load
func save_run(score: int, distance: float, bones: int) -> void:
	last_score    = score
	last_distance = distance
	last_bones    = bones
	if score > highscore:
		highscore = score
	if distance > best_distance:
		best_distance = distance
	_save()

# Write persistent data to disk
func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "highscore",     highscore)
	cfg.set_value("progress", "best_distance", best_distance)
	cfg.set_value("progress", "levels_unlocked", levels_unlocked)
	cfg.save(SAVE_PATH)

# Load persistent data if save file exists
func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	highscore        = cfg.get_value("progress", "highscore",       0)
	best_distance    = cfg.get_value("progress", "best_distance",   0.0)
	levels_unlocked  = cfg.get_value("progress", "levels_unlocked", 1)

# Scene navigation
func go_to_level(level_number: int) -> void:
	# Change to a specific level scene
	current_level = level_number
	get_tree().change_scene_to_file(LEVELS[level_number])

# It goes to game over scene
func go_to_game_over() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/GameOver.tscn")

# It returns to main menu
func go_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

# It goes to win scene
func go_to_you_win() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/YouWin.tscn")

# Progression
func complete_level() -> void:
	if current_level >= levels_unlocked:
		levels_unlocked = current_level + 1
		_save()
	# Always show the win screen; it decides whether to go next or stay on final
	go_to_you_win()
