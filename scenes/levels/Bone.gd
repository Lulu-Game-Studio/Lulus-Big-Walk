extends Area2D

# Add this object to the bone group
func _ready() -> void:
	add_to_group("bone")
	
	# Detect when a body enters the area
	body_entered.connect(func(b: Node):
		# Check if the body is the player and this node is still valid
		if b.is_in_group("player") and is_instance_valid(self):
			# Get the current level instance
			var level = get_tree().get_first_node_in_group("level")
			
			# Notofy the level that a bone was collected 
			if level and level.has_method("on_bone_collected"):
				level.on_bone_collected()
				# Remove the bone from the scene when is collected
			queue_free()
	)
