class_name Damage_Manager extends Node

# Signals to notify other systems
signal player_damaged(target, amount)
signal player_died(target)

func apply_damage(target: Node, amount: float, source: Node = null, knockback: Vector2 = Vector2.ZERO):
	if not target or not target.has_method("apply_damage"):
		push_warning("Invalid target: %s" % target)
		return
		
	target.apply_damage(amount, source)
	emit_signal("player_damaged", target, amount)
	print("%s took %.1f damage" % [name, amount])
	
	# Apply knockback if any
	if knockback != Vector2.ZERO and target is Player and not target.dead:
		_apply_knockback(target, source, knockback)
		
	if target.dead:
		emit_signal("player_died", target)

func instant_kill(target: Node, source: Node = null):
	apply_damage(target, 2, source)

func _apply_knockback(player: Player, source: Node, knockback: Vector2):
	# Determine direction away from source
	if source:
		var direction = (player.global_position - source.global_position).normalized()
		player.velocity = direction * knockback.length()
		player.velocity.y = knockback.y
	else:
		player.velocity = knockback
