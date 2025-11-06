extends RigidBody2D
class_name Barrel

@export var damage: int = 1
@export var knockback_force: Vector2 = Vector2(400, -250)
@export var respawn_time: float = 3.0
@export var bounce_impulse: float = 250.0
@export var fall_limit_y: float = 1000.0

@onready var spawn_position: Vector2 = global_position
@onready var spawn_rotation: float = rotation

var active := true
var recently_hit_bodies: Array = []

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 8
	apply_central_impulse(Vector2(bounce_impulse, 0))

	# Start a repeating Timer to handle respawn
	var t = Timer.new()
	t.wait_time = 0.1
	t.one_shot = false
	t.autostart = true
	add_child(t)
	t.connect("timeout", Callable(self, "_check_respawn"))

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if not active:
		return

	for i in range(state.get_contact_count()):
		var normal: Vector2 = state.get_contact_local_normal(i)

		# Bounce horizontally off walls
		if abs(normal.x) > 0.7:
			linear_velocity.x = -linear_velocity.x * 0.8
			apply_central_impulse(Vector2(bounce_impulse * sign(linear_velocity.x), 0))

		# Slight upward bounce on floor
		elif normal.y < -0.7 and abs(linear_velocity.y) > 10:
			linear_velocity.y = -linear_velocity.y * 0.4

func _on_body_entered(body: Node) -> void:
	if not active:
		return

	if body is Player: #and not body.invincible:
		#if body in recently_hit_bodies:
		#	return
		#recently_hit_bodies.append(body)

		var dir := int(sign(body.global_position.x - global_position.x))
		var kb := Vector2(knockback_force.x * dir, knockback_force.y)
		DamageManager.apply_damage(body, damage, self, kb)

		#_erase_recent_hit(body)

#func _erase_recent_hit(body: Node) -> void:
#	recently_hit_bodies.erase(body)

# --- Respawn check called by timer ---
func _check_respawn() -> void:
	if global_position.y > fall_limit_y or not active:
		_respawn()

func _respawn() -> void:
	active = false
	$CollisionShape2D.disabled = true
	visible = false
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0

	# Use a one-shot timer to delay respawn
	var t = Timer.new()
	t.wait_time = respawn_time
	t.one_shot = true
	t.autostart = true
	add_child(t)
	t.connect("timeout", Callable(self, "_finish_respawn"))

func _finish_respawn() -> void:
	global_position = spawn_position
	rotation = spawn_rotation
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	$CollisionShape2D.disabled = false
	visible = true
	active = true

	# Give it a small roll
	apply_central_impulse(Vector2(bounce_impulse, 0))
