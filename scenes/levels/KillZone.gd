extends Area2D

# Connect a callback when a body enters this area
func _ready() -> void:
	body_entered.connect(func(b: Node):
		# Check if the body is the player
		if b.is_in_group("player") and b.has_method("die"):
			# Trigger the player's death
			b.die()
	)
