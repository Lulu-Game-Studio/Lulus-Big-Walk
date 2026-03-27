extends Node2D

# Cached references to scene nodes for quick access
@onready var label_bones  : Label        = $HUD/Stats/BoneLabel
@onready var label_dist   : Label        = $HUD/Stats/DistLabel
@onready var label_score  : Label        = $HUD/Stats/ScoreLabel
@onready var mischief_bar : ProgressBar  = $HUD/MischiefBar
@onready var frenzy_label : Label        = $HUD/FrenzyLabel
@onready var camera       : Camera2D     = $Camera2D
@onready var lulu         : CharacterBody2D = $Lulu
@onready var music        : AudioStreamPlayer = $Music

# Base movement speed and how it scales over distance
const BASE_SPEED      := 250.0
const SPEED_INCREMENT := 18.0
const MAX_SPEED       := 560.0

# Core gameplay stats
var bones_collected      := 0
var score                := 0
var distance             := 0.0

# Internal state variables
var _start_x             := 0.0   # Initial player X position
var _speed_level         := 0     # Current speed tier
var _running             := false # Whether the game is active
var _game_over_triggered := false # Prevents multiple game over triggers

func _ready() -> void:
	# Add this node to a group for easy access elsewhere
	add_to_group("level")

	# Store initial player position
	_start_x = lulu.position.x

	# Initialize player speed
	lulu.run_speed = BASE_SPEED

	# Connect player signals to this controller
	lulu.mischief_gained.connect(_on_mischief_changed)
	lulu.died.connect(_on_lulu_died)

	# Initialize UI
	_update_hud()

	# Start game loop
	_running = true

	# Play background music
	music.play()

func _process(delta: float) -> void:
	# Skip updates if game is stopped or player no longer exists
	if not _running or not is_instance_valid(lulu):
		return

	# Smoothly move camera horizontally ahead of the player
	camera.position.x = lerp(camera.position.x, lulu.position.x + 120.0, 8.0 * delta)

	# Smoothly follow player vertically, clamped within limits
	camera.position.y = lerp(
		camera.position.y,
		clamp(
			lulu.position.y - 60.0,
			float(camera.limit_top + 100),
			float(camera.limit_bottom - 100)
		),
		5.0 * delta
	)

	# Update distance based on player movement (converted to "meters")
	distance = max((lulu.position.x - _start_x) / 48.0, distance)

	# Score calculation:
	# - Distance contributes steadily
	# - Bones give bonus points
	score = int(distance) * 10 + bones_collected * 50

	# Determine speed level based on distance
	var spd_lvl := int(distance / 400.0)

	# Increase speed only when reaching a new level
	if spd_lvl > _speed_level:
		_speed_level = spd_lvl

		# Increase player speed but cap it at MAX_SPEED
		lulu.run_speed = min(BASE_SPEED + _speed_level * SPEED_INCREMENT, MAX_SPEED)

	# Refresh UI
	_update_hud()

func _update_hud() -> void:
	# Update all HUD elements safely (check if nodes exist)
	if label_bones:
		label_bones.text = "🦴  %d" % bones_collected

	if label_dist:
		label_dist.text  = "📍  %dm" % int(distance)

	if label_score:
		label_score.text = "⭐  %d" % score

	# Update mischief bar if player is valid
	if mischief_bar and is_instance_valid(lulu):
		mischief_bar.value = lulu.mischief

func _on_mischief_changed(value: int) -> void:
	# Ignore if UI element is missing
	if not is_instance_valid(mischief_bar):
		return

	# Handle different mischief states
	match value:
		-1:
			# Special "frenzy" state
			mischief_bar.value   = 10
			frenzy_label.visible = true

		0:
			# Empty state
			mischief_bar.value   = 0
			frenzy_label.visible = false

		_:
			# Normal state
			mischief_bar.value   = value
			frenzy_label.visible = false

func on_bone_collected() -> void:
	# Increase bone counter
	bones_collected += 1

	# Notify player (for effects, animations, etc.)
	if is_instance_valid(lulu):
		lulu.on_bone_collected()

func _on_lulu_died() -> void:
	# Prevent multiple executions of game over logic
	if _game_over_triggered:
		return

	_game_over_triggered = true
	_running = false

	# Stop music
	music.stop()

	# Save run data (score, distance, collectibles)
	GameManager.save_run(score, distance, bones_collected)

	# Small delay before switching scene
	await get_tree().create_timer(1.2).timeout

	# Transition to game over screen
	GameManager.go_to_game_over()

func trigger_game_over() -> void:
	# External method to force game over
	_on_lulu_died()
