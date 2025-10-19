class_name BaseScene extends Node

@onready var entrance_markers = $EntranceMarkers
@onready var camera = $Camera2D

func _ready():
	for p in sceneManager.players:
		if not is_instance_valid(p):
			continue
		add_child(p)
		position_player(p)


func position_player(p: Player) -> void:
	var last_scene = sceneManager.last_scene_name
	if last_scene.is_empty():
		last_scene = "any"
	
	for entrace in entrance_markers.get_children():
		if entrace is Marker2D and entrace.name == last_scene:
			var offset = Vector2(20,0) if p == sceneManager.players[0] else Vector2(-20,0)
			p.position = entrace.global_position + offset
			
			var speed = p.velocity.length()
			if speed != 0:
				p.velocity = p.velocity.normalized() * round(speed * 0.5)
