extends Node2D

# ── Node refs (all exist in the .tscn, nothing built at runtime) ──────────────
@onready var label_bones  : Label        = $HUD/Stats/BoneLabel
@onready var label_dist   : Label        = $HUD/Stats/DistLabel
@onready var label_score  : Label        = $HUD/Stats/ScoreLabel
@onready var mischief_bar : ProgressBar  = $HUD/MischiefBar
@onready var frenzy_label : Label        = $HUD/FrenzyLabel
@onready var camera       : Camera2D     = $Camera2D
@onready var lulu         : CharacterBody2D = $Lulu
@onready var music        : AudioStreamPlayer = $Music

# ── Speed progression ─────────────────────────────────────────────────────────
const BASE_SPEED      := 220.0
const SPEED_INCREMENT := 15.0
const MAX_SPEED       := 520.0

# ── Public state (read by Goal.gd / Bone.gd) ─────────────────────────────────
var bones_collected      := 0
var score                := 0
var distance             := 0.0

var _start_x             := 0.0
var _speed_level         := 0
var _running             := false
var _game_over_triggered := false

# ── Ready ─────────────────────────────────────────────────────────────────────
func _ready() -> void:
	add_to_group("level")

	_start_x       = lulu.position.x
	lulu.run_speed = BASE_SPEED
	lulu.mischief_gained.connect(_on_mischief_changed)
	lulu.died.connect(_on_lulu_died)

	_update_hud()
	_running = true
	music.play()

# ── Per-frame ─────────────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	if not _running or not is_instance_valid(lulu):
		return

	# Smooth camera: lead ahead of Lulu
	camera.position.x = lerp(camera.position.x, lulu.position.x + 120.0, 8.0 * delta)
	camera.position.y = lerp(
		camera.position.y,
		clamp(lulu.position.y - 60.0, float(camera.limit_top + 100), float(camera.limit_bottom - 100)),
		5.0 * delta
	)

	# Distance and score
	distance = max((lulu.position.x - _start_x) / 48.0, distance)
	score    = int(distance) * 10 + bones_collected * 50

	# Speed up every 500 m
	var spd_lvl := int(distance / 500.0)
	if spd_lvl > _speed_level:
		_speed_level   = spd_lvl
		lulu.run_speed = min(BASE_SPEED + _speed_level * SPEED_INCREMENT, MAX_SPEED)

	_update_hud()

# ── HUD ───────────────────────────────────────────────────────────────────────
func _update_hud() -> void:
	if label_bones:  label_bones.text = "🦴  %d" % bones_collected
	if label_dist:   label_dist.text  = "📍  %dm" % int(distance)
	if label_score:  label_score.text = "⭐  %d" % score
	if mischief_bar and is_instance_valid(lulu):
		mischief_bar.value = lulu.mischief

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

# ── Callbacks (called by Bone.gd) ─────────────────────────────────────────────
func on_bone_collected() -> void:
	bones_collected += 1
	if is_instance_valid(lulu):
		lulu.on_bone_collected()

# ── Death / Game Over ─────────────────────────────────────────────────────────
func _on_lulu_died() -> void:
	if _game_over_triggered:
		return
	_game_over_triggered = true
	_running = false
	music.stop()
	GameManager.save_run(score, distance, bones_collected)
	await get_tree().create_timer(1.2).timeout
	GameManager.go_to_game_over()

func trigger_game_over() -> void:
	_on_lulu_died()
