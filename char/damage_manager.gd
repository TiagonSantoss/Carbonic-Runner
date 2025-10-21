class_name Damage_Manager extends Node

# Signals to notify other systems
signal player_damaged(target, amount)
signal player_died(target)

# Apply generic damage
func apply_damage(target: Node, amount: float, source: Node = null):
	if not target or not target.has_method("apply_damage"):
		push_warning("Invalid target: %s" % target)
		return

	target.apply_damage(amount, source)
	emit_signal("player_damaged", target, amount)

	if target.dead:
		emit_signal("player_died", target)

# Instant kill helper
func instant_kill(target: Node, source: Node = null):
	apply_damage(target, 9999, source)
