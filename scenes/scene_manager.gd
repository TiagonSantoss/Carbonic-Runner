class_name scene_manager extends Node

var players: Array = []
var last_scene_name: String
var dir = "res://scenes/"

func change_scene(from, to_scene: String) -> void:
	last_scene_name = from.name
	
	var new_players: Array[Player] = []
	
	for child in from.get_children():
		if child is Player:
			if is_instance_valid(child) and not new_players.has(child):
				new_players.append(child)
				child.get_parent().remove_child(child)
				
	for old_p in players:
		if is_instance_valid(old_p) and not new_players.has(old_p):
			old_p.queue_free()
	players = new_players.duplicate()
	for child in from.get_children():
		if child is Player:
			players.append(child)
			child.get_parent().remove_child(child)
	var full_path = dir + to_scene + ".tscn"
	from.get_tree().call_deferred("change_scene_to_file", full_path)
