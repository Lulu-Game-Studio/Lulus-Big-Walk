extends Area2D
func _ready() -> void:
	body_entered.connect(func(b: Node):
		if b.is_in_group("player"):
			var level = get_tree().get_first_node_in_group("level")
			if level:
				GameManager.save_run(level.score, level.distance, level.bones_collected)
			GameManager.complete_level()
	)
