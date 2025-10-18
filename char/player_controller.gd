class_name PlayerController extends Node

var active_player: Player
var follower_player: Player
var camera: Camera2D
var right := false

@export var max_distance := 1200.0
@export var follow_distance := 100.0
#@export var follow_speed := 5000.0

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
	#follower_player.global_position = lerp(follower_player.global_position, active_player.global_position, 0.2)
	if dist > max_distance:
		# Too far: move directly toward player ignoring obstacles
		follower_player.global_position = follower_player.global_position.lerp(active_player.global_position, 0.25)
		follower_player.velocity.x = 0
	else:
		if dist > follow_distance:
			dir = dir.normalized()
			var target_velocity_x = dir.x * follower_player.max_speed
			follower_player.velocity.x = lerp(follower_player.velocity.x, target_velocity_x, follower_player.ground_accel * delta)
		else:
			follower_player.velocity.x = lerp(follower_player.velocity.x, 0.0, follower_player.ground_friction * delta)

	# Flip sprite based on horizontal movement
	if abs(follower_player.velocity.x) > 0.1:
		follower_player.sprite.flip_h = follower_player.velocity.x < 0
	elif dist > max_distance:
		# If catching up by lerp, flip based on direction to player
		follower_player.sprite_2D.flip_h = dir.x < 0

	# Flip sprite
	if abs(follower_player.velocity.x) > 0.1:
		follower_player.sprite_2D.flip_h = follower_player.velocity.x < 0

func update_animations(player1, player2):
	var player_list = [player1, player2]
	var speed_mult = 1.0
	for player in player_list:
		var anim_name := ""
		if player.is_on_floor():
			if abs(player.velocity.x) > 0.1:
				anim_name = "Walk"
			else:
				anim_name = "Idle"
			player.jumping = false
		else:
			if player.velocity.y < 0:
				if not player.jump_played:
					anim_name = "Jump"
					player.jump_played = true
			elif player.velocity.y > 0:
				anim_name = "Fall"
			else:
				anim_name = player.animation_player.current_animation
				if anim_name == "":
					anim_name = "Jump"
					
		if anim_name != player.animation_player.current_animation:
			if anim_name == "Jump":
				var speed_factor = min(player.max_jump_time / player.jump_timer, 1.0)
				speed_mult = 1.5 * speed_factor if player.name == "player2" else 0.2 * speed_factor
			else:
				speed_mult = 1.0
		player.play_generic(anim_name, speed_mult)

func update_camera(delta):
	if is_instance_valid(camera) and is_instance_valid(active_player):
		camera.global_position = camera.global_position.lerp(active_player.global_position, 30 * delta)
