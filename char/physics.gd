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
@onready var sprite1 = $Sprite1
var animation_to_play = "Idle"
var jump_played = false
var right = true

# --- FOLLOWER ---
var control_enabled: bool = true
var is_follower: bool = false

# --- Thy end is now! Die! ---
@onready var collision = $CollisionShape2D
var dead: bool = false
var invincible := false
@export var health = 2

# --- Wall Jumping ---
var on_wall: bool = false
var wall_dir: int = 0  # -1 = left wall, 1 = right wall
var wall_jump_active := false

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
	on_wall = is_on_wall()
	if on_wall:
		var wall_normal = get_wall_normal()
		wall_dir = int(sign(wall_normal.x))
	else:
		wall_dir = 0
	#print(wall_dir)
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
		coyote_timer -= delta
	else:
		if velocity.y > 0:
			velocity.y = 0
		coyote_timer = coyote_time
		jump_played = false
			
func handle_jump(delta: float):
	var jump_pressed := Input.is_action_just_pressed("jump")
	var jump_held := Input.is_action_pressed("jump")

	if on_wall and not is_on_floor() and velocity.y > 0:
		var wall_slide_speed := 150.0  # tweak
		velocity.y = lerp(velocity.y, wall_slide_speed, delta * 10.0)

	# --- WALL HOLD PUSH ---
	#if on_wall and jump_held and not is_on_floor():
	#	var wall_push := 300.0  # horizontal push speed
	#	velocity.x = wall_push * wall_dir  # move away from wall

	if jump_pressed:
		if is_on_floor() or coyote_timer > 0.5:
			velocity.y = jump_force
			jumping = true
			jump_timer = 0.0
			coyote_timer = 0.0
		elif on_wall:
			# Wall jump
			velocity.y = jump_force
			velocity.x = move_speed * 0.5 * wall_dir  # initial push away from wall
			jumping = true
			jump_timer = 0.0
			coyote_timer = 0.0

	# --- VARIABLE HEIGHT JUMP ---
	if jumping and jump_held and jump_timer < max_jump_time:
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
			
	#sprite_2D.flip_h = not right #velocity.x < 0 if abs(velocity.x) > 0.1 else sprite_2D.flip_h

#func update_animation() -> void:
#	if is_on_floor():
#		animation_to_play = "Walk" if abs(velocity.x) > 0.1 else "Idle"
#	else:
#		if velocity.y < 0 and not jump_played:
#			animation_to_play = "Jump"
#			jump_played = true
#		else:
#			animation_to_play = "Fall"
#	sprite_2D.flip_h = not right
#	if animation_player.current_animation != animation_to_play:
#		animation_player.play(animation_to_play)

func set_follower(state: bool) -> void:
	is_follower = state
	control_enabled = not state
	print("Sprite2D:", sprite_2D)

	var mat = sprite_2D.material as ShaderMaterial
	if is_follower:
		invincible = true
		mat.set_shader_parameter("follower_gray", 1.0)   # should turn gray
	else:
		invincible = false
		mat.set_shader_parameter("follower_gray", 0.0)
	mat.set_shader_parameter("flash_strength", 0.0)

@warning_ignore("unused_parameter")
func apply_damage(amount: float, source: Node = null, knockback := Vector2.ZERO) -> void:
	if dead or invincible:
		return
	
	health -= amount
	PlayerManager._health_changed.emit()
	apply_iframes(1.0)
	#print("%s took %s damage" % [name, amount])
	
	velocity += knockback  # optional knockback
	
	if health <= 0:
		die()

func apply_iframes(duration: float) -> void:
	#get_tree().paused = true
	#if is_follower: return
	invincible = true
	var elapsed := 0.0
	var flash_interval := 0.1
	#t.wait_time = flash_interval / 2
	#t.one_shot = true
	#t.autostart = true
	var mat = sprite_2D.material as ShaderMaterial
	while elapsed < duration:
		mat.set_shader_parameter("flash_strength", 1.0)
		await get_tree().create_timer(flash_interval / 2).timeout
		mat.set_shader_parameter("flash_strength", 0.0)
		await get_tree().create_timer(flash_interval / 2).timeout
		elapsed += flash_interval
	invincible = is_follower
	sprite_2D.material.set_shader_parameter("flash_strength", 0.0)
	if is_follower:
		mat.set_shader_parameter("follower_gray", 1.0)
	else:
		mat.set_shader_parameter("follower_gray", 0.0)

	#get_tree().paused = false
	#await t.timeout
	#t.queue_free()

func die():
	if dead:
		return
	dead = true
	
	control_enabled = false
	collision.set_deferred("disabled", true)
	set_physics_process(true)
	
	z_index = 100
	sprite_2D.modulate = Color(1, 1, 1, 0.7)
	velocity = Vector2(randf_range(-100, 100), -800)
	
	DamageManager.emit_signal("player_died", self)
	
