extends Area2D
func _ready() -> void:
	add_to_group("bone")
	body_entered.connect(func(b: Node):
		if b.is_in_group("player") and is_instance_valid(self):
			var level = get_tree().get_first_node_in_group("level")
			if level and level.has_method("on_bone_collected"):
				level.on_bone_collected()
			queue_free()
	)
