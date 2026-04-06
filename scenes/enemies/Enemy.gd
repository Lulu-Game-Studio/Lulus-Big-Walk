extends CharacterBody2D

const GRAVITY       := 900.0
const JUMP_VX       := 80.0
const JUMP_VY       := -340.0
const JUMP_INTERVAL := 2.2
const STUN_DURATION := 1.5

@onready var anim   : AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox : Area2D           = $Hitbox

var _dead       : bool  = false
var _stunned    : bool  = false
var _stun_timer : float = 0.0
var _stun_tween : Tween = null
var _jump_timer : float = 0.8

func _ready() -> void:
	add_to_group("enemy")
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	anim.animation_finished.connect(_on_anim_finished)
	anim.play("idle")

func _physics_process(delta: float) -> void:
	if _dead:
		if not is_on_floor():
			velocity.y += GRAVITY * delta
		move_and_slide()
		return

	# Stun from bark
	if _stunned:
		_stun_timer -= delta
		if _stun_timer <= 0.0:
			_stunned = false
		velocity.x = 0.0
		if is_on_floor():
			_play("idle")
		if not is_on_floor():
			velocity.y += GRAVITY * delta
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y += GRAVITY * delta
		_play("fall" if velocity.y > 0 else "jump")
	else:
		velocity.x = 0.0
		velocity.y = 0.0
		_play("idle")
		_jump_timer -= delta
		if _jump_timer <= 0.0:
			_do_jump()

	move_and_slide()

func _do_jump() -> void:
	_jump_timer = JUMP_INTERVAL
	var player = get_tree().get_first_node_in_group("player")
	var dir := 1.0
	if player:
		dir = sign(player.position.x - position.x)
	anim.flip_h = dir < 0
	velocity.x  = dir * JUMP_VX
	velocity.y  = JUMP_VY
	_play("jump")

# Called by Lulu's bark ability
func stun() -> void:
	if _dead:
		return
	if _stunned:   # second bark → dead
		if _stun_tween:
			_stun_tween.kill()  # ← it kills the tween before dead
		die()
		return
	_stunned    = true
	_stun_timer = STUN_DURATION
	velocity    = Vector2.ZERO
	if _stun_tween:
		_stun_tween.kill()
	_stun_tween = create_tween().set_loops(3)
	_stun_tween.tween_property(anim, "modulate", Color(2.0, 2.0, 2.0, 1.0), 0.1)
	_stun_tween.tween_property(anim, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.15)

func die() -> void:
	if _dead:
		return
	_dead = true
	set_physics_process(false)
	hitbox.set_deferred("monitoring", false)
	velocity = Vector2.ZERO
	anim.modulate = Color(1, 1, 1, 1)
	anim.play("death")

func _play(a: String) -> void:
	if anim.animation != a:
		anim.play(a)

func _on_hitbox_body_entered(body: Node) -> void:
	if _dead or _stunned or not body.is_in_group("player"):
		return
	# Check if player is in frenzy — if so, kill the enemy instead
	if body.get("frenzy_active") == true:
		die()
		return
	body.die()

func _on_anim_finished() -> void:
	if anim.animation == &"death":
		queue_free()
