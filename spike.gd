extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		DamageManager.apply_damage(body, 9999, self, Vector2(0, -100))
