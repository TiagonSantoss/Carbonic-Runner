class_name BaseScene
extends Node

@onready var entrance_markers = $EntranceMarkers
@onready var camera = $Camera2D

func _ready():
	# If we just loaded a new scene and players exist, add them in
	if PlayerManager.players.size() > 0:
		add_existing_players(PlayerManager.players, sceneManager.last_scene_name)

func add_existing_players(players: Array, last_scene: String) -> void:
	for p in players:
		if not is_instance_valid(p):
			continue
		PlayerManager.remove_child(p)
		add_child(p)
		position_player(p, last_scene)

func position_player(p: Player, last_scene: String) -> void:
	var chosen_marker: Marker2D = null
	for entrance in entrance_markers.get_children():
		if entrance is Marker2D and entrance.name == last_scene:
			chosen_marker = entrance
			break
	if chosen_marker == null:
		for entrance in entrance_markers.get_children():
			if entrance is Marker2D:
				chosen_marker = entrance
				break
	if chosen_marker:
		var offset = Vector2(20, 0) if p == PlayerManager.players[0] else Vector2(-20, 0)
		p.global_position = chosen_marker.global_position + offset
