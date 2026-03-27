extends Node

# Time before automatically advancing to the next screen
const AUTO_ADVANCE_TIME := 4.0

# UI Node References
@onready var title_label   : Label  = $Panel/VBox/TitleLabel
@onready var sub_label     : Label  = $Panel/VBox/SubLabel
@onready var countdown_lbl : Label  = $Panel/VBox/CountdownLabel
@onready var next_btn      : Button = $Panel/VBox/NextButton
@onready var menu_btn      : Button = $Panel/VBox/MenuButton
@onready var music : AudioStreamPlayer = $AudioStreamPlayer

# Preloaded win scene music
var WinMusic = preload("res://assets/audio/WinScene.mp3")
var _timer   : float = AUTO_ADVANCE_TIME
var _ticking : bool  = true

func _ready() -> void:
	var next_level := GameManager.current_level + 1
	var has_next   := GameManager.LEVELS.has(next_level)
	
	# Play win music
	music.stream = WinMusic
	music.play()

# Player completed a level and can continue
	if has_next:
		title_label.text      = "GOOD JOB!"
		sub_label.text        = "Level %d completed!" % GameManager.current_level
		next_btn.text         = "Next level ▶"
		next_btn.visible      = true
		countdown_lbl.visible = true
		_ticking              = true
	# Player finished all levels
	else:
		title_label.text      = "FANTASTIC!"
		sub_label.text        = "All levels completed!\nCongratulations!"
		next_btn.text         = "Back to menu"
		next_btn.visible      = false
		countdown_lbl.visible = false
		_ticking              = false

	next_btn.pressed.connect(_on_next)
	menu_btn.pressed.connect(_on_menu)

	# Fade in animation for the panel
	$Panel.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property($Panel, "modulate:a", 1.0, 0.5)

# Handle automatic transition countdown
func _process(delta: float) -> void:
	if not _ticking:
		return
	_timer -= delta
	if _timer <= 0.0:
		_ticking = false
		_on_next()
	else:
		countdown_lbl.text = "Continuing in %d…" % ceili(_timer)

# Proceed to next level or fallback to menu
func _on_next() -> void:
	_ticking = false
	var next_level := GameManager.current_level + 1
	if GameManager.LEVELS.has(next_level):
		GameManager.go_to_level(next_level)
	else:
		GameManager.go_to_menu()

# Return to main menu
func _on_menu() -> void:
	_ticking = false
	GameManager.go_to_menu()
