extends Node
class_name Music_Manager

@export var fade_speed: float = 3.0	# seconds for fade in/out

var current_player: AudioStreamPlayer
var next_player: AudioStreamPlayer

func _ready():
	# create two players so we can crossfade
	current_player = AudioStreamPlayer.new()
	next_player = AudioStreamPlayer.new()
	add_child(current_player)
	add_child(next_player)
	
func play_music(new_stream: AudioStream):
	# if there’s no music playing yet
	if current_player.stream == null:
		current_player.stream = new_stream
		current_player.volume_db = -16
		current_player.play()
		_fade_in(current_player)
		return
	
	# otherwise, crossfade to the new track
	next_player.stream = new_stream
	next_player.volume_db = -16
	next_player.play()
	
	# fade out the old one and fade in the new one
	_fade_out(current_player)
	_fade_in(next_player)
	
	# swap references after fade
	await get_tree().create_timer(fade_speed).timeout
	current_player.stop()
	var temp = current_player
	current_player = next_player
	next_player = temp
	
func _fade_in(player: AudioStreamPlayer) -> void:
	create_tween().tween_property(
		player, "volume_db", -16, fade_speed
	)

func _fade_out(player: AudioStreamPlayer) -> void:
	create_tween().tween_property(
		player, "volume_db", -80, fade_speed
	)
