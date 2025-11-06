extends Control

@onready var rat_button: Button = $RATRATRATRAT
@onready var pen_button: Button = $PENPENPENPEN
var rat
var pen

func setup() -> void:
	# Connect button presses safely
	rat_button.pressed.connect(_on_rat_pressed)
	pen_button.pressed.connect(_on_pen_pressed)

	# Highlight on hover (mouse) and focus (keyboard/gamepad)
	rat_button.mouse_entered.connect(func(): rat_button.grab_focus())
	pen_button.mouse_entered.connect(func(): pen_button.grab_focus())

	# Set default focus to PEN
	pen_button.grab_focus()

	# Add highlight scaling
	_scale_buttons()
	rat = preload("res://char/rato.tscn").instantiate()
	pen = preload("res://char/pinguim.tscn").instantiate()
	PlayerManager.rat = rat
	PlayerManager.pen = pen

func _on_rat_pressed() -> void:
	_on_character_selected("RAT")

func _on_pen_pressed() -> void:
	_on_character_selected("PEN")

func _on_character_selected(character_name: String) -> void:
	print(PlayerManager.pen)
	#PlayerManager.switch_players()
	if character_name == "RAT":
		PlayerManager.active_player = PlayerManager.rat
		PlayerManager.follower_player = PlayerManager.pen
	else:
		PlayerManager.active_player = PlayerManager.pen
		PlayerManager.follower_player = PlayerManager.rat
	get_tree().change_scene_to_file("res://scenes/outside.tscn")
	
	visible = false  # Hide character select (optional)

func _scale_buttons() -> void:
	for button in [rat_button, pen_button]:
		button.connect("focus_entered", func(): button.scale = Vector2(1.2, 1.2))
		button.connect("focus_exited", func(): button.scale = Vector2(1, 1))
