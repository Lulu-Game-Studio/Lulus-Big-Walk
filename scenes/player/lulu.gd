extends CharacterBody2D

# Constants
const BASE_SPEED       := 220.0
const JUMP_FORCE       := -500.0
const GRAVITY          := 1200.0
const JUMP_BUFFER_TIME := 0.14
const STOMP_BOUNCE     := -320.0
const DOUBLE_JUMP_MULT := 0.80

# Display scaling
const DISPLAY_SCALE := Vector2(0.28, 0.28)

# Mischief system
const MISCHIEF_MAX    := 10
const FRENZY_DURATION := 8.0

# Level-controlled state
var run_speed : float = BASE_SPEED

#  Node references
@onready var anim          : AnimatedSprite2D    = $AnimatedSprite2D
@onready var coyote_timer  : Timer               = $CoyoteTimer
@onready var bark_cooldown : Timer               = $BarkCooldown
@onready var poop_cooldown : Timer               = $PoopCooldown
@onready var snd_jump      : AudioStreamPlayer2D = $SndJump
@onready var snd_hurt      : AudioStreamPlayer2D = $SndHurt
@onready var snd_item      : AudioStreamPlayer2D = $SndItem

# State
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

# Process
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
	_handle_movement()
	_handle_jump()
	_handle_actions()
	move_and_slide()
	_check_stomp()
	_update_animation()

# Movement
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		if was_on_floor:
			coyote_timer.start()
	else:
		coyote_available = true
		double_jumped    = false

func _handle_movement() -> void:
	if is_barking or is_pooping:
		# Slow to a stop while doing special action
		velocity.x = move_toward(velocity.x, 0.0, 600.0 * get_physics_process_delta_time())
		return

	var spd := run_speed * (2.0 if frenzy_active else 1.0)
	var dir := 0.0

	if Input.is_action_pressed("move_right"):
		dir += 1.0
	if Input.is_action_pressed("move_left"):
		dir -= 1.0

	if dir != 0.0:
		velocity.x = dir * spd
		anim.flip_h = dir < 0.0
	else:
		# Stand still when no key pressed
		velocity.x = move_toward(velocity.x, 0.0, 600.0 * get_physics_process_delta_time())

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

# Mischief
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

# Collectible callback
func on_bone_collected() -> void:
	snd_item.play()

# Death
func die() -> void:
	if is_dead or frenzy_active:
		return
	is_dead    = true
	velocity.x = 0.0
	velocity.y = -200.0
	snd_hurt.play()
	_play("hurt")
	died.emit()

# Stomp
func _check_stomp() -> void:
	if velocity.y <= 0:
		return
	for i in range(get_slide_collision_count()):
		var col      = get_slide_collision(i)
		var collider = col.get_collider()
		if collider and collider.is_in_group("enemy") and col.get_normal().y < -0.5:
			collider.die()
			velocity.y = STOMP_BOUNCE

# Animation
func _update_animation() -> void:
	if is_barking or is_pooping or is_dead:
		return
	if not is_on_floor():
		_play("jump")
	elif Input.is_action_pressed("ui_down"):
		_play("sit")
		velocity.x = move_toward(velocity.x, 0.0, 600.0 * get_physics_process_delta_time())
	elif abs(velocity.x) > 10.0:
		_play("run")
	else:
		_play("idle")

func _play(anim_name: String) -> void:
	if anim.animation != anim_name:
		anim.play(anim_name)

func _on_anim_finished() -> void:
	match anim.animation:
		&"bark":
			is_barking = false
		&"poop":
			is_pooping = false
			_spawn_poop()

func _on_coyote_timer_timeout() -> void:
	coyote_available = false

# Poop spawning
func _spawn_poop() -> void:
	var poop_node := _make_poop_node()
	# Place poop at Lulu's feet, slightly behind her
	var offset_x := 24.0 if anim.flip_h else -24.0
	poop_node.global_position = global_position + Vector2(offset_x, 20.0)
	get_parent().add_child(poop_node)

func _make_poop_node() -> Node2D:
	var root := Node2D.new()
	root.name = "PoopPile"
	root.z_index = 1

	# Emoji label for the poop
	var lbl := Label.new()
	lbl.text = "💩"
	lbl.add_theme_font_size_override("font_size", 28)
	lbl.position = Vector2(-14, -28)
	root.add_child(lbl)

	# Area2D so enemies can detect poop (optional)
	var area := Area2D.new()
	var shape := CollisionShape2D.new()
	var circ  := CircleShape2D.new()
	circ.radius = 14.0
	shape.shape  = circ
	shape.position = Vector2(0, -8)
	area.add_child(shape)
	area.add_to_group("poop_pile")
	root.add_child(area)

	# Auto-remove after 6 seconds with a fade
	var timer := Timer.new()
	timer.wait_time = 6.0
	timer.one_shot  = true
	timer.autostart = true
	root.add_child(timer)
	timer.timeout.connect(func():
		var tw := root.create_tween()
		tw.tween_property(root, "modulate:a", 0.0, 1.0)
		tw.tween_callback(root.queue_free)
	)

	return root
