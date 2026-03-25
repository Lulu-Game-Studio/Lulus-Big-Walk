extends Node

const AUTO_ADVANCE_TIME := 5.0   # seconds before auto-advancing

@onready var title_label   : Label       = $Panel/VBox/TitleLabel
@onready var sub_label     : Label       = $Panel/VBox/SubLabel
@onready var countdown_lbl : Label       = $Panel/VBox/CountdownLabel
@onready var next_btn      : Button      = $Panel/VBox/NextButton
@onready var menu_btn      : Button      = $Panel/VBox/MenuButton
@onready var stars_anim    : AnimationPlayer = $StarsAnim

var _timer   : float = AUTO_ADVANCE_TIME
var _ticking : bool  = true

func _ready() -> void:
	var next_level := GameManager.current_level + 1
	var has_next   := GameManager.LEVELS.has(next_level)

	if has_next:
		title_label.text = "YOU WIN! 🐾"
		sub_label.text   = "Level %d complete!" % GameManager.current_level
		next_btn.text    = "Next Level ▶"
		next_btn.visible = true
		countdown_lbl.visible = true
	else:
		title_label.text = "YOU WIN! 🏆"
		sub_label.text   = "All levels complete!\nLulu is the best dog!"
		next_btn.text    = "Play Again"
		next_btn.visible = true
		countdown_lbl.visible = false
		_ticking = false

	next_btn.pressed.connect(_on_next)
	menu_btn.pressed.connect(_on_menu)

	# Animate panel in
	$Panel.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.6)

func _process(delta: float) -> void:
	if not _ticking:
		return
	_timer -= delta
	if _timer <= 0.0:
		_ticking = false
		_on_next()
	else:
		countdown_lbl.text = "Next level in %d…" % ceili(_timer)

func _on_next() -> void:
	_ticking = false
	var next_level := GameManager.current_level + 1
	if GameManager.LEVELS.has(next_level):
		GameManager.go_to_level(next_level)
	else:
		GameManager.go_to_level(1)

func _on_menu() -> void:
	_ticking = false
	GameManager.go_to_menu()
