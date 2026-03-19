extends CharacterBody2D

func _ready() -> void:
	add_to_group("player")

# ── Constants ──────────────────────────────────────────────────────
const SPEED          := 200.0
const JUMP_FORCE     := -480.0
const GRAVITY        := 1200.0
const RUN_THRESHOLD  := 180.0
const JUMP_BUFFER_TIME := 0.12

# ── Nodes ──────────────────────────────────────────────────────────
@onready var anim         : AnimatedSprite2D = $AnimatedSprite2D
@onready var coyote_timer : Timer            = $CoyoteTimer

# ── State ──────────────────────────────────────────────────────────
var coyote_available := false
var jump_buffer      := 0.0
var was_on_floor     := false

# ── Process ────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	jump_buffer  = max(jump_buffer - delta, 0.0)
	was_on_floor = is_on_floor()

# ── Physics ────────────────────────────────────────────────────────
func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_movement()
	_handle_jump()
	move_and_slide()
	_update_animation()

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		# Empieza coyote time al dejar el suelo
		if was_on_floor:
			coyote_timer.start()
	else:
		coyote_available = true

func _handle_movement() -> void:
	var dir := Input.get_axis("ui_left", "ui_right")
	velocity.x = dir * SPEED
	if dir != 0:
		anim.flip_h = dir < 0

func _handle_jump() -> void:
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer = JUMP_BUFFER_TIME

	if jump_buffer > 0.0 and (is_on_floor() or coyote_available):
		velocity.y      = JUMP_FORCE
		coyote_available = false
		jump_buffer      = 0.0

# ── Animation ──────────────────────────────────────────────────────
func _update_animation() -> void:
	if not is_on_floor():
		_play("jump")
	elif Input.is_action_pressed("ui_down"):
		_play("sit")
	elif abs(velocity.x) >= RUN_THRESHOLD:
		_play("run")
	elif abs(velocity.x) > 0:
		_play("walk")
	else:
		_play("idle")

func _play(anim_name: String) -> void:
	if anim.animation != anim_name:
		anim.play(anim_name)

func _on_coyote_timer_timeout() -> void:
	coyote_available = false
