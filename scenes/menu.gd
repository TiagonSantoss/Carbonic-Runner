extends Control

@onready var play_button: Button = $Menu/Button
@onready var character_select: Control = $CharacterSelect

func _ready() -> void:
	character_select.visible = false
	MusicManager.play_music(preload("res://world/sound/Menu.wav"))

	play_button.grab_focus()
	_highlight_button(play_button, true)

	play_button.pressed.connect(_on_play_pressed)
	play_button.focus_entered.connect(func(): _highlight_button(play_button, true))
	play_button.mouse_entered.connect(func(): _highlight_button(play_button, true))
	play_button.focus_exited.connect(func(): _highlight_button(play_button, false))
	play_button.mouse_exited.connect(func(): _highlight_button(play_button, false))
	play_button.mouse_entered.connect(func(): play_button.grab_focus())

func _highlight_button(button: Button, focused: bool) -> void:
	button.scale = Vector2(1.2, 1.2) if focused else Vector2(1.0, 1.0)

func _on_play_pressed() -> void:
	$Menu.visible = false
	character_select.visible = true
	character_select.call("setup")

	# Move focus to PEN by default
	#var pen_button := character_select.get_node("PenButton")
	#if pen_button:
	#	pen_button.grab_focus()
