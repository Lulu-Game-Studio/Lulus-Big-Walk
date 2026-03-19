extends Node2D

var bones_collected := 0
var bones_total    := 0

@onready var hud_label : Label = $HUD/BoneLabel
@onready var camera    : Camera2D = $Camera2D
@onready var lulu      : CharacterBody2D = $Lulu

func _ready() -> void:
	for bone in get_tree().get_nodes_in_group("bone"):
		bone.collected.connect(_on_bone_collected)
	bones_total = get_tree().get_nodes_in_group("bone").size()
	_update_hud()

func _process(_delta: float) -> void:
	# Camera follows Lulu horizontally, locked vertically
	camera.position.x = lulu.position.x
	camera.position.y = 128

func _on_bone_collected() -> void:
	bones_collected += 1
	_update_hud()

func _update_hud() -> void:
	if hud_label:
		hud_label.text = "🦴 %d / %d" % [bones_collected, bones_total]
