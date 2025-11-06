extends Control
class_name LifeUI

@export var life_textures: Array[Texture2D]
@onready var icons = {
	"Rat": $VBoxContainer/rat/rat,
	"Pen": $VBoxContainer/pen/pen
}

@onready var lives_digits = {
	"Rat": $VBoxContainer/rat/Lrat,
	"Pen": $VBoxContainer/pen/Lpen
}

func _ready() -> void:
	_update_display()
	
	if PlayerManager.has_signal("_health_changed"):
		PlayerManager._health_changed.connect(_update_display)

func _update_display() -> void:
	await get_tree().create_timer(0.2).timeout
	var rat_lives = PlayerManager.follower_player.health
	var pen_lives = PlayerManager.active_player.health
	if PlayerManager.follower_player.name == "player2":
		rat_lives = PlayerManager.follower_player.health
		pen_lives = PlayerManager.active_player.health
	else:
		rat_lives = PlayerManager.active_player.health
		pen_lives = PlayerManager.follower_player.health

	_set_life_texture("Rat", rat_lives)
	_set_life_texture("Pen", pen_lives)

func _set_life_texture(character: String, lives: int) -> void:
	if character in lives_digits:
		var clamped_lives = clamp(lives, 0, life_textures.size() - 1)
		lives_digits[character].texture = life_textures[clamped_lives]
