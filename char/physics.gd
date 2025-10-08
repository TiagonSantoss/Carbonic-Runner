extends CharacterBody2D
class_name Player

#GRAV
@export var gravity = 900
@export var jump_force = -400
@export var max_jump_time = 0.3
@export var move_speed = 500
@export var max_fall_speed = 1000
var jump_timer = 0.0
var jumping = false
#GROUND
@export var ground_accel = 20.0
@export var ground_friction = 15.0
#AIR
@export var air_accel = 5.0
@export var air_friction = 2.0
#COYOTE
@export var coyote_time = 1.2
var coyote_timer = 0.0
#ANIMATION
@onready var animation_player:AnimationPlayer = $AnimationPlayer
@onready var sprite_2D:Sprite2D = $Sprite2D
var animation_direction = "Right"
var animation_to_play = "Idle"
var last_facing = "Left"
var jump_played = false

func _ready() -> void:
	animation_player.stop()
	animation_player.play("Idle")
	
func _physics_process(delta) -> void:
	#GRAVITY
	if not is_on_floor():
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, max_fall_speed)
		coyote_timer -= delta
	else:
		if velocity.y > 0:
			velocity.y = 0.0
		coyote_timer = coyote_time
		jump_timer = 0.0
		jumping = false
		jump_played = false
		
	#MOVEMENT
	var input_dir = Input.get_axis("ui_left", "ui_right")
	if is_on_floor():
		handle_movement(input_dir, ground_accel, ground_friction, delta)
	else:
		handle_movement(input_dir, air_accel, air_friction, delta)
		
	var cols = is_touching("gel")
	print(cols)
	#print(round(velocity.length()))
	#JUMP
	if Input.is_action_just_pressed("jump") and (is_on_floor() or coyote_timer > 1.0) and not jumping:
		velocity.y = jump_force
		jumping = true
		jump_timer = 0.0
		coyote_timer = 0.0
		
	if Input.is_action_pressed("jump") and jumping:
		if jump_timer < max_jump_time:
			velocity.y += (jump_force * 1.2) * delta 
			jump_timer += delta
	else:
		jumping = false
		
	#ANIMATION
	var raw_input = Input.get_vector("ui_left", "ui_right", "jump", "ui_down")
	
	if raw_input.x != 0:
		last_facing = "Left" if raw_input.x < 0.0 else "Right"
		
	if is_on_floor():
		animation_to_play = "Walk" if round(velocity.length() * 10) / 10 > 0.0 else "Idle"
	else:
		if velocity.y < 0:
			if not jump_played:
				animation_to_play = "Jump"
				jump_played = true
		else:
			animation_to_play = "Fall"
		
	var speed_multiplier = 0.0
	if animation_to_play == "Jump":
		var jump_progress = min(max_jump_time / jump_timer, 1.0)
		speed_multiplier = 0.2 * jump_progress
	else:
		speed_multiplier = 1.2
		
	sprite_2D.flip_h = (last_facing == "Left")
	
	if animation_player.current_animation != animation_to_play:
		animation_player.play(animation_to_play, -1, 1.0)
	animation_player.speed_scale = speed_multiplier
	move_and_slide()
	
func handle_movement(input_dir, accel, friction, delta):
	if input_dir != 0:
		var target = input_dir * move_speed
		velocity.x = lerp(velocity.x, target, accel * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction * delta)

func is_touching(type) -> bool:
	for i in range(get_slide_collision_count()):
		var col = get_slide_collision(i)
		
		if col.get_collider() is TileMapLayer:
			var tilemap: TileMapLayer = col.get_collider()
			var cell = tilemap.local_to_map(col.get_position())
			var tile_data = tilemap.get_cell_tile_data(cell)
			
			if tile_data:
				print(tile_data.get_custom_data("type"))
				return true
				
	return false
