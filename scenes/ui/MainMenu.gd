extends Node

# UI node references
@onready var play_button     : Button = $VBoxContainer/PlayButton
@onready var quit_button     : Button = $VBoxContainer/QuitButton
@onready var music : AudioStreamPlayer = $AudioStreamPlayer

# Preloaded main menu music track
var mainMenuMusic = preload("res://assets/audio/Splitting the Fields - Jon Björk.mp3")

# Connect button signals to their respective handlers
func _ready() -> void:
	play_button.pressed.connect(_on_play)
	quit_button.pressed.connect(_on_quit)
	play_button.grab_focus() # Initial focus to play button
	music.stream = mainMenuMusic
	music.play()

func _on_play() -> void:
	GameManager.go_to_level(1) # Start the game by loading level 1

func _on_quit() -> void:
	get_tree().quit() # Exit the game

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_on_play()
