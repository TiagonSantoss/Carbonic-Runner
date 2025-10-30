class_name PlayerController extends Node

var active_player: Player
var follower_player: Player
var camera: Camera2D
#var right := false

@export var max_distance := 700.0
@export var follow_distance := 200.0
#@export var follow_speed := 5000.0

func _ready():
	#process_mode = Node.PROCESS_MODE_ALWAYS      # ensures _process runs even if tree paused
	#physics_process_mode = Node.PROCESS_MODE_ALWAYS  # ensures _physics_process runs even if tree paused
	DamageManager.connect("player_damaged", Callable(self, "_on_player_damaged"))
	DamageManager.connect("player_died", Callable(self, "_on_player_died"))

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
	#active_player.dead = false
	if active_player.dead:
		active_player.dead = false
	active_player.apply_iframes(1.5)

func update_follower(delta: float):
	if not is_instance_valid(active_player) or not is_instance_valid(follower_player):
		return
	var dir = active_player.global_position - follower_player.global_position
	var dist = dir.length()
	#follower_player.global_position = lerp(follower_player.global_position, active_player.global_position + Vector2(-10, -20), 0.2)
	#follower_player.t.process_mode = Timer.ProcessMode.PROCESS_MODE_ALWAYS
	if not follower_player.dead:
		if dist > max_distance:
			follower_player.collision.set_deferred("disabled", true)
			dir = dir.normalized()
			var catch_up_speed = follower_player.move_speed * 1.5  # 3× normal speed
			var target_vel_x = dir.x * catch_up_speed
			var target_vel_y = dir.y * catch_up_speed
			follower_player.velocity.x = lerp(
				follower_player.velocity.x,
				target_vel_x,
				follower_player.ground_accel * 60 * delta
			)
			follower_player.velocity.x = lerp(
				follower_player.velocity.y,
				target_vel_y,
				follower_player.air_accel * 60 * delta
			)
		else:
			follower_player.collision.set_deferred("disabled", false)
			if dist > follow_distance:
				dir = dir.normalized()
				var target_velocity_x = dir.x * active_player.move_speed * 2.0
				var target_velocity_y = dir.y * active_player.move_speed * 2.0
				follower_player.velocity.x = lerp(follower_player.velocity.x, target_velocity_x, follower_player.ground_accel * 3.0 * delta)
				follower_player.velocity.y = lerp(follower_player.velocity.y, target_velocity_y, follower_player.air_accel * 3.0 * delta)
			else:
				follower_player.velocity.x = lerp(follower_player.velocity.x, 0.0, follower_player.ground_friction * delta)
				follower_player.velocity.y = lerp(follower_player.velocity.y, 0.0, follower_player.air_friction * delta)
	var flip_offset := 36.0
	var is_flipped = not active_player.right
	
	if follower_player:
		follower_player.sprite_2D.flip_h = is_flipped
		if is_flipped:
			follower_player.sprite_2D.position.x = flip_offset
		else:
			follower_player.sprite_2D.position.x = 0
	if active_player.name == "player2":
		if is_flipped:
			active_player.sprite_2D.position.x = flip_offset
		else:
			active_player.sprite_2D.position.x = 0

	#if follower_player:
	#	if abs(follower_player.velocity.x) > 0.1:
	#		follower_player.sprite_2D.flip_h = follower_player.velocity.x < 0
	#	elif dist > max_distance:
	#		# If catching up by lerp, flip based on direction to player
	#		follower_player.sprite_2D.flip_h = dir.x < 0

	# Flip sprite
	#if abs(follower_player.velocity.x) > 0.1:
	#	follower_player.sprite_2D.flip_h = follower_player.velocity.x < 0

func update_animations(player1, player2):
	var player_list = [player1, player2]
	var speed_mult = 1.0
	for player in player_list:
		var anim_name := ""
		if player.is_on_floor():
			if abs(player.velocity.x) * 10 > 0.1:
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
					
		if anim_name == player.animation_player.current_animation:
			if anim_name == "Jump":
				print(name, " -> Jump chosen; vel.y:", player.velocity.y, "jump_played:", player.jump_played)
				var speed_factor = min(player.max_jump_time / player.jump_timer, 1.0)
				speed_mult = 2.0 * speed_factor if player.name == "player2" else 0.2 * speed_factor
			else:
				speed_mult = 1.0
		player.sprite_2D.flip_h = not player.right
		player.play_generic(anim_name, speed_mult)

func update_camera(_delta):
	if is_instance_valid(camera) and is_instance_valid(active_player):
		camera.global_position = active_player.global_position
		

func _on_player_damaged(_target, _amount):
	# Optional: show hit effects, camera shake, etc.
	pass

func _on_player_died(target):
	if target == active_player:
		if not follower_player.dead:
			follower_player.global_position = lerp(follower_player.global_position + Vector2(-40, -100), active_player.global_position, 0.2)
			switch_players() # only switch if there’s a living follower
	# Check game over regardless
	if not is_any_player_alive():
		game_over()

#func switch_to_alive_player():
#	if not follower_player.dead:
#		switch_players()
#		active_player = follower_player
#		active_player.set_follower(false)
#		follower_player.set_follower(true)

func is_any_player_alive() -> bool:
	return not active_player.dead or not follower_player.dead

func game_over():
	#TO DO!!!!
	print("Both players dead → Game Over!")
	#await 3
	get_tree().paused = true
	#var game_over_scene = preload("res://ui/GameOver.tscn").instantiate()
	#get_tree().current_scene.add_child(game_over_scene)
	pass
