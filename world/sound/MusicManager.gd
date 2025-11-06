extends Node
class_name Music_Manager

@export var fade_speed: float = 0.8 # seconds

var current_player: AudioStreamPlayer
var next_player: AudioStreamPlayer
var fade_tweens: Array[Tween] = []

func _ready():
	current_player = AudioStreamPlayer.new()
	next_player = AudioStreamPlayer.new()
	add_child(current_player)
	add_child(next_player)

func _clear_tweens():
	for t in fade_tweens:
		if t.is_valid():
			t.kill()
	fade_tweens.clear()

func play_music(new_stream: AudioStream):
	# Kill any ongoing tweens before changing anything
	_clear_tweens()

	if current_player.stream == null:
		current_player.stream = new_stream
		current_player.volume_db = -16
		current_player.play()
		_fade_in(current_player)
		return

	next_player.stream = new_stream
	next_player.volume_db = -80
	next_player.play()

	_fade_out(current_player)
	_fade_in(next_player)

	# Swap references immediately
	var old = current_player
	current_player = next_player
	next_player = old

	await get_tree().create_timer(fade_speed).timeout
	old.stop()

func _fade_in(player: AudioStreamPlayer) -> void:
	var t = create_tween()
	t.tween_property(player, "volume_db", -10, fade_speed)
	fade_tweens.append(t)

func _fade_out(player: AudioStreamPlayer) -> void:
	var t = create_tween()
	t.tween_property(player, "volume_db", -20, fade_speed)
	fade_tweens.append(t)

func stop():
	_clear_tweens()
	if current_player:
		current_player.stop()
	if next_player:
		next_player.stop()
