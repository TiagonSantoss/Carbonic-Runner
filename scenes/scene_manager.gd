class_name scene_manager extends Node

var player: Player
var last_scene_name: String
var dir = "res://scenes/"

func change_scene(from, to_scene: String) -> void:
	last_scene_name = from.name
	player = from.get_node("player")
	if player:
		player.get_parent().remove_child(player)
		
		var full_path = dir + to_scene + ".tscn"
		from.get_tree().call_deferred("change_scene_to_file", full_path)
