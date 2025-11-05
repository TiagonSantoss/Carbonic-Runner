extends Area2D
class_name Obstacle

@onready var col = $CollisionShape2D
@onready var anim = $AnimationPlayer
@onready var sprite = $Sprite2D
@export var wait_seconds = 2.0
@export var knockback_force: Vector2 = Vector2(400, 0)

func _ready() -> void:
	col.disabled = true
	_start_cycle()

func _start_cycle() -> void:
	anim.play("splash")
	col.disabled = false
	await get_tree().create_timer(1.1).timeout
	col.disabled = true
	await get_tree().create_timer(wait_seconds).timeout
	_start_cycle()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.invincible: return
		var dir := int(sign(body.global_position.x - global_position.x))
		var kb := Vector2(knockback_force.x * dir, knockback_force.y)
		DamageManager.apply_damage(body, 1, self, kb)
