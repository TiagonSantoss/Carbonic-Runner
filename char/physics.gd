extends CharacterBody2D
class_name Player

# --- PHYSICS ---
@export var gravity = 1200
@export var gravity_mult = 1.0
@export var jump_force = -400
@export var max_jump_time = 0.8
@export var hold_jump_multiplier = 1.0
@export var move_speed = 500
@export var max_fall_speed = 1000
@export var ground_accel = 20.0
@export var ground_friction = 15.0
@export var air_accel = 5.0
@export var air_friction = 2.0
@export var coyote_time = 0.2

var jump_timer = 0.0
var jumping = false
var coyote_timer = 0.0

# --- ANIMATION ---
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2D: Sprite2D = $Sprite2D
var animation_to_play = "Idle"
var jump_played = false
var right: bool

# --- FOLLOWER ---
var control_enabled: bool = true
var is_follower: bool = false

func _ready():
	print(name, "animations:", animation_player.get_animation_list())
	animation_player.stop()
	animation_player.play("Idle")
	
func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	var input_dir = 0.0
	if control_enabled:
		input_dir = Input.get_axis("ui_left","ui_right")
		if Input.is_action_pressed("ui_right"):
			right = true
		elif Input.is_action_pressed("ui_left"):
			right = false
	handle_movement(input_dir,delta)
	handle_jump(delta)
	move_and_slide()
#	update_animation()

func handle_movement(input_dir: float, delta: float) -> void:
	var accel = ground_accel if is_on_floor() else air_accel
	var friction = ground_friction if is_on_floor() else air_friction
	
	if input_dir != 0:
		var target = input_dir * move_speed
		velocity.x = lerp(velocity.x, target, accel * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction * delta)

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		#velocity.y += gravity * gravity_mult * delta
		if Input.is_action_pressed("ui_down") and not is_on_floor():
			velocity.y += int(gravity * gravity_mult) * delta
		else:
			velocity.y += gravity * delta
		#velocity.y = min(velocity.y, max_fall_speed)
		#coyote_timer -= delta
	else:
		if velocity.y > 0:
			velocity.y = 0
		coyote_timer = coyote_time
		jump_played = false
			
func handle_jump(delta: float):
	if Input.is_action_just_pressed("jump") and (is_on_floor() or coyote_timer > 0.0)and not jumping:
		velocity.y = jump_force
		jumping = true
		jump_timer = 0.0
		coyote_timer = 0.0
		
	
	if Input.is_action_pressed("jump") and jumping and jump_timer < max_jump_time:
		var hold_factor = 1.0 - (jump_timer / max_jump_time)
		var adjusted_gravity = -gravity * (hold_jump_multiplier * hold_factor)
		velocity.y += adjusted_gravity * delta
		jump_timer += delta
	else:
		jumping = false
			
func play_generic(anim_name: String, speed: float = 1.0) -> void:
	if anim_name == "":
		return
		
	if animation_player.current_animation != anim_name:
		if animation_player.has_animation(anim_name):
			animation_player.play(anim_name, -1, speed)
		else:
			push_warning("Animation not found for %s: %s" % [self.name, anim_name])
	sprite_2D.flip_h = not right

func update_animation() -> void:
	if is_on_floor():
		animation_to_play = "Walk" if abs(velocity.x) > 0.1 else "Idle"
	else:
		if velocity.y < 0 and not jump_played:
			animation_to_play = "Jump"
			jump_played = true
		else:
			animation_to_play = "Fall"
	sprite_2D.flip_h = not right
	if animation_player.current_animation != animation_to_play:
		animation_player.play(animation_to_play)

func set_follower(state: bool) -> void:
	is_follower = state
	control_enabled = not state
	if is_follower:
		sprite_2D.modulate = Color(0.6, 0.6, 0.6, 1)
	else:
		sprite_2D.modulate = Color(1, 1, 1, 1)
