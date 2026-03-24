extends CharacterBody2D

# ── Constants ─────────────────────────────────────────────────────────────────
const BASE_SPEED       := 220.0
const JUMP_FORCE       := -500.0
const GRAVITY          := 1200.0
const JUMP_BUFFER_TIME := 0.14
const STOMP_BOUNCE     := -320.0
const DOUBLE_JUMP_MULT := 0.80

# All Lulu sprites are 256×256 — no scale correction needed between animations
# Set a display scale so she fits the 16px tile world (SCALE=3 → 48px tiles)
# 256px sprite displayed at scale 0.28 ≈ 71px tall ≈ reasonable for a dog
const DISPLAY_SCALE := Vector2(0.28, 0.28)

# Mischief
const MISCHIEF_MAX    := 10
const FRENZY_DURATION := 8.0

# ── Level-controlled state ────────────────────────────────────────────────────
var run_speed : float = BASE_SPEED

# ── Nodes ─────────────────────────────────────────────────────────────────────
@onready var anim          : AnimatedSprite2D    = $AnimatedSprite2D
@onready var coyote_timer  : Timer               = $CoyoteTimer
@onready var bark_cooldown : Timer               = $BarkCooldown
@onready var poop_cooldown : Timer               = $PoopCooldown
@onready var snd_jump      : AudioStreamPlayer2D = $SndJump
@onready var snd_hurt      : AudioStreamPlayer2D = $SndHurt
@onready var snd_item      : AudioStreamPlayer2D = $SndItem

# ── State ─────────────────────────────────────────────────────────────────────
var coyote_available := false
var jump_buffer      := 0.0
var was_on_floor     := false
var double_jumped    := false
var is_barking       := false
var is_pooping       := false
var is_dead          := false

var mischief         := 0
var frenzy_active    := false
var frenzy_timer     := 0.0
var _frenzy_tween    : Tween = null

signal mischief_gained(amount: int)
signal died

# ── Ready ─────────────────────────────────────────────────────────────────────
func _ready() -> void:
	add_to_group("player")
	anim.scale = DISPLAY_SCALE
	anim.animation_finished.connect(_on_anim_finished)
	anim.play("idle")

# ── Process ───────────────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	jump_buffer  = max(jump_buffer - delta, 0.0)
	was_on_floor = is_on_floor()
	if frenzy_active:
		frenzy_timer -= delta
		if frenzy_timer <= 0.0:
			_end_frenzy()

func _physics_process(delta: float) -> void:
	if is_dead:
		_apply_gravity(delta)
		move_and_slide()
		return
	_apply_gravity(delta)
	_handle_autorun()
	_handle_jump()
	_handle_actions()
	move_and_slide()
	_check_stomp()
	_update_animation()

# ── Movement ──────────────────────────────────────────────────────────────────
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		if was_on_floor:
			coyote_timer.start()
	else:
		coyote_available = true
		double_jumped    = false

func _handle_autorun() -> void:
	if is_barking or is_pooping:
		# Slow to a stop while doing special action
		velocity.x = move_toward(velocity.x, 0.0, 600.0 * get_physics_process_delta_time())
		return
	var spd := run_speed * (2.0 if frenzy_active else 1.0)
	velocity.x = spd
	anim.flip_h = false

func _handle_jump() -> void:
	if is_barking or is_pooping or is_dead:
		return
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("jump"):
		jump_buffer = JUMP_BUFFER_TIME
	if jump_buffer > 0.0 and (is_on_floor() or coyote_available):
		velocity.y       = JUMP_FORCE
		coyote_available = false
		jump_buffer      = 0.0
		double_jumped    = false
		snd_jump.play()
	elif jump_buffer > 0.0 and not is_on_floor() and not double_jumped:
		velocity.y    = JUMP_FORCE * DOUBLE_JUMP_MULT
		double_jumped = true
		jump_buffer   = 0.0
		snd_jump.play()

func _handle_actions() -> void:
	# Bark: Z
	if Input.is_action_just_pressed("bark") \
			and bark_cooldown.is_stopped() \
			and not is_barking and not is_pooping:
		is_barking = true
		bark_cooldown.start()
		_play("bark")
		_add_mischief(1)
		_bark_stun_enemies()

	# Poo shield: P
	if Input.is_action_just_pressed("poo") \
			and poop_cooldown.is_stopped() \
			and not is_pooping and not is_barking:
		is_pooping = true
		poop_cooldown.start()
		_play("poop")
		_add_mischief(2)

# ── Mischief ─────────────────────────────────────────────────────────────────
func _add_mischief(amount: int) -> void:
	if frenzy_active:
		return
	mischief = min(mischief + amount, MISCHIEF_MAX)
	mischief_gained.emit(mischief)
	if mischief >= MISCHIEF_MAX:
		_start_frenzy()

func _start_frenzy() -> void:
	frenzy_active = true
	frenzy_timer  = FRENZY_DURATION
	mischief      = 0
	if _frenzy_tween:
		_frenzy_tween.kill()
	_frenzy_tween = create_tween().set_loops()
	_frenzy_tween.tween_property(anim, "modulate", Color(1.6, 1.0, 0.15), 0.12)
	_frenzy_tween.tween_property(anim, "modulate", Color(1.0, 1.0, 1.0),  0.12)
	mischief_gained.emit(-1)

func _end_frenzy() -> void:
	frenzy_active = false
	if _frenzy_tween:
		_frenzy_tween.kill()
		_frenzy_tween = null
	anim.modulate = Color(1, 1, 1, 1)
	mischief_gained.emit(0)

func _bark_stun_enemies() -> void:
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy.has_method("stun") and enemy.position.distance_to(position) < 180.0:
			enemy.stun()

# ── Collectible callback ──────────────────────────────────────────────────────
func on_bone_collected() -> void:
	snd_item.play()

# ── Death ─────────────────────────────────────────────────────────────────────
func die() -> void:
	if is_dead or frenzy_active:
		return
	is_dead    = true
	velocity.x = 0.0
	velocity.y = -200.0
	snd_hurt.play()
	_play("hurt")
	died.emit()

# ── Stomp ─────────────────────────────────────────────────────────────────────
func _check_stomp() -> void:
	if velocity.y <= 0:
		return
	for i in range(get_slide_collision_count()):
		var col      = get_slide_collision(i)
		var collider = col.get_collider()
		if collider and collider.is_in_group("enemy") and col.get_normal().y < -0.5:
			collider.die()
			velocity.y = STOMP_BOUNCE

# ── Animation ─────────────────────────────────────────────────────────────────
func _update_animation() -> void:
	if is_barking or is_pooping or is_dead:
		return
	if not is_on_floor():
		_play("jump")
	elif Input.is_action_pressed("ui_down"):
		_play("sit")
		velocity.x = move_toward(velocity.x, 0.0, 600.0 * get_physics_process_delta_time())
	else:
		_play("run")

func _play(anim_name: String) -> void:
	if anim.animation != anim_name:
		anim.play(anim_name)

func _on_anim_finished() -> void:
	match anim.animation:
		&"bark":
			is_barking = false
		&"poop":
			is_pooping = false

func _on_coyote_timer_timeout() -> void:
	coyote_available = false
