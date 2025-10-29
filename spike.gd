extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.invincible: return
		print("colliding")
		DamageManager.apply_damage(body, 1, self, Vector2(0,-800))
