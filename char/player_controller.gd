class_name PlayerController extends Node

var active_player: Player
var follower_player: Player
var camera: Camera2D

@export var follow_distance := 100.0
@export var follow_speed := 300.0

func set_players(active: Player, follower: Player) -> void:
	active_player = active
	follower_player = follower
	follower_player.set_follower(true)

func switch_players():
	var temp = active_player
	active_player = follower_player
	follower_player = temp
	active_player.set_follower(false)
	follower_player.set_follower(true)

func update_follower(delta: float):
	if not is_instance_valid(active_player) or not is_instance_valid(follower_player):
		return

	var dir = active_player.global_position - follower_player.global_position
	var dist = dir.length()
	if dist > follow_distance:
		dir = dir.normalized()
		follower_player.velocity.x = move_toward(follower_player.velocity.x, dir.x * active_player.velocity.x, 600 * delta)
	else:
		follower_player.velocity.x = move_toward(follower_player.velocity.x, 0, 300 * delta)

	# Apply gravity
	follower_player.velocity.y += follower_player.gravity * delta
	follower_player.move_and_slide()

	# Flip sprite
	#if dir.x != 0:
	#	follower_player.sprite_2D.flip_h = dir.x < 0

	# Optional: mimic jump
	if follower_player.is_on_floor() and active_player.velocity.y < 0 and active_player.global_position.y + 5 < follower_player.global_position.y:
		follower_player.velocity.y = active_player.jump_force

func update_camera(delta):
	if is_instance_valid(camera) and is_instance_valid(active_player):
		camera.global_position = camera.global_position.lerp(active_player.global_position, 30 * delta)
