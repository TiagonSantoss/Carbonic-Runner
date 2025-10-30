extends Control

@onready var rat_button: Button = $RATRATRATRAT
@onready var pen_button: Button = $PENPENPENPEN

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

func _on_rat_pressed() -> void:
	_on_character_selected("RAT")

func _on_pen_pressed() -> void:
	_on_character_selected("PEN")

func _on_character_selected(character_name: String) -> void:
	print("Selected character:", character_name)
	#PlayerManager.switch_players()
	get_tree().change_scene_to_file("res://scenes/outside.tscn")
	
	visible = false  # Hide character select (optional)

func _scale_buttons() -> void:
	for button in [rat_button, pen_button]:
		button.connect("focus_entered", func(): button.scale = Vector2(1.2, 1.2))
		button.connect("focus_exited", func(): button.scale = Vector2(1, 1))
