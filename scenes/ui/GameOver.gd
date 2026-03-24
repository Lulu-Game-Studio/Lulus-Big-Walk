extends Node

@onready var retry_button    : Button = $VBoxContainer/RetryButton
@onready var menu_button     : Button = $VBoxContainer/MenuButton
@onready var score_label     : Label  = $StatsContainer/ScoreLabel
@onready var dist_label      : Label  = $StatsContainer/DistLabel
@onready var bone_label      : Label  = $StatsContainer/BoneLabel
@onready var highscore_label : Label  = $StatsContainer/HighscoreLabel

func _ready() -> void:
	retry_button.pressed.connect(_on_retry)
	menu_button.pressed.connect(_on_menu)
	retry_button.grab_focus()

	# Pull last run stats from GameManager
	var gm := GameManager
	score_label.text     = "⭐  %d puntos" % gm.last_score
	dist_label.text      = "📍  %d metros" % int(gm.last_distance)
	bone_label.text      = "🦴  %d huesos" % gm.last_bones
	highscore_label.text = "🏆  Récord: %d" % gm.highscore

	# Animate stats in
	for child in $StatsContainer.get_children():
		child.modulate.a = 0.0
		var tw := create_tween()
		tw.tween_property(child, "modulate:a", 1.0, 0.4).set_delay(0.15 * $StatsContainer.get_children().find(child))

func _on_retry() -> void:
	GameManager.go_to_level(GameManager.current_level)

func _on_menu() -> void:
	GameManager.go_to_menu()
