class_name BaseScene extends Node

@onready var player = $player
@onready var entrance_markers = $EntranceMarkers

func _ready():
	if sceneManager.player:
		if player:
			player.queue_free()
		player = sceneManager.player
		add_child(player)
	position_player()


func position_player() -> void:
	var last_scene = sceneManager.last_scene_name
	if last_scene.is_empty():
		last_scene = "any"
	
	print(last_scene)
	for entrace in entrance_markers.get_children():
		if entrace is Marker2D and entrace.name == last_scene:
			player.position = entrace.global_position
