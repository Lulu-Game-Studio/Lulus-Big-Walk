extends Area2D

# Connect a callback to detect when a body enters this area
func _ready() -> void:
	body_entered.connect(func(b: Node):
		# Check if the entering body is the player
		if b.is_in_group("player"):
			# Get the current level instance
			var level = get_tree().get_first_node_in_group("level")
			
			# Save current run stats if level exists
			if level:
				GameManager.save_run(level.score, level.distance, level.bones_collected)
			
			# Trigger level completion
			GameManager.complete_level()
	)
