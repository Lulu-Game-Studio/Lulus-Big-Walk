extends Node

@onready var play_button     : Button = $VBoxContainer/PlayButton
@onready var quit_button     : Button = $VBoxContainer/QuitButton
@onready var music : AudioStreamPlayer = $AudioStreamPlayer

var mainMenuMusic = preload("res://assets/audio/Splitting the Fields - Jon Björk.mp3")

func _ready() -> void:
	play_button.pressed.connect(_on_play)
	quit_button.pressed.connect(_on_quit)
	play_button.grab_focus()
	music.stream = mainMenuMusic
	music.play()

func _on_play() -> void:
	GameManager.go_to_level(1)

func _on_quit() -> void:
	get_tree().quit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_on_play()
