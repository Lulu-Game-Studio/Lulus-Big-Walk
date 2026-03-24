extends Area2D
func _ready() -> void:
	body_entered.connect(func(b: Node):
		if b.is_in_group("player") and b.has_method("die"):
			b.die()
	)
