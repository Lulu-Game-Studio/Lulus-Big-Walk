extends Node2D

class_name Levels

# Node references
@onready var label_bones  : Label        = $HUD/Stats/BoneLabel
@onready var label_dist   : Label        = $HUD/Stats/DistLabel
@onready var label_score  : Label        = $HUD/Stats/ScoreLabel
@onready var mischief_bar : ProgressBar  = $HUD/MischiefBar
@onready var frenzy_label : Label        = $HUD/FrenzyLabel
@onready var camera       : Camera2D     = $Camera2D
@onready var lulu         : CharacterBody2D = $Lulu
@onready var music        : AudioStreamPlayer = $Music

# Game stats 
var bones_collected      := 0 # Number of collected bones
var score                := 0 # Current score
var distance             := 0.0 # Distance traveled in meters

var _start_x             := 0.0 # Initial X position for distance tracking
var _speed_level         := 0 # Current speed progression level
var _running             := false # Whether level is active
var _game_over_triggered := false # Prevents multiple game over calls

func _ready() -> void:
	add_to_group("level")

	_start_x = lulu.position.x
	lulu.run_speed = get_base_speed()

# Connect player signals
	lulu.mischief_gained.connect(_on_mischief_changed)
	lulu.died.connect(_on_lulu_died)

	_update_hud()
	_running = true
	music.play()

func _process(delta: float) -> void:
	# Skip updates if the game isn't running or player is invalid
	if not _running or not is_instance_valid(lulu):
		return

#Smooth camera follow
	camera.position.x = lerp(camera.position.x, lulu.position.x + get_camera_lead_x(), get_camera_lerp_x() * delta)
	camera.position.y = lerp(
		camera.position.y,
		clamp(lulu.position.y - 60.0, float(camera.limit_top + 100), float(camera.limit_bottom - 100)),
		5.0 * delta
	)

# Update distance and score
	distance = max((lulu.position.x - _start_x) / 48.0, distance)
	score    = int(distance) * 10 + bones_collected * 50

	_update_speed_level()
	_update_hud()

func _update_speed_level() -> void:
	#Increase speed elvel basedd on distance thresholds
	var spd_lvl := int(distance / get_speed_up_distance())
	if spd_lvl > _speed_level:
		_speed_level = spd_lvl
		lulu.run_speed = min(get_base_speed() + _speed_level * get_speed_increment(), get_max_speed())

#Update UI elements if they exist
func _update_hud() -> void:
	if label_bones:  label_bones.text = "🦴  %d" % bones_collected
	if label_dist:   label_dist.text  = "📍  %dm" % int(distance)
	if label_score:  label_score.text = "⭐  %d" % score
	if mischief_bar and is_instance_valid(lulu):
		mischief_bar.value = lulu.mischief

# Handle special mischief states and UI feedback
func _on_mischief_changed(value: int) -> void:
	if not is_instance_valid(mischief_bar):
		return
	match value:
		-1:
			mischief_bar.value   = 10
			frenzy_label.visible = true
		0:
			mischief_bar.value   = 0
			frenzy_label.visible = false
		_:
			mischief_bar.value   = value
			frenzy_label.visible = false

# Increase bone count and notify player
func on_bone_collected() -> void:
	bones_collected += 1
	if is_instance_valid(lulu):
		lulu.on_bone_collected()

# Prevent duplicate game over execution
func _on_lulu_died() -> void:
	if _game_over_triggered:
		return
	_game_over_triggered = true
	_running = false
	music.stop()

	# Save run data and transition to game over
	GameManager.save_run(score, distance, bones_collected)
	await get_tree().create_timer(1.2).timeout
	GameManager.go_to_game_over()

# External trigget for game over
func trigger_game_over() -> void:
	_on_lulu_died()

# Overridable settings
func get_base_speed() -> float:
	return 220.0

func get_speed_increment() -> float:
	return 15.0

func get_max_speed() -> float:
	return 520.0

func get_speed_up_distance() -> float:
	return 500.0

func get_camera_lead_x() -> float:
	return 120.0

func get_camera_lerp_x() -> float:
	return 8.0
