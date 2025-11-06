class_name scene_Manager
extends Node

var dir := "res://scenes/"
var is_changing_scene := false
var last_scene_name := ""

func change_scene(from: Node, to_scene: String) -> void:
	if is_changing_scene:
		return
	is_changing_scene = true
	last_scene_name = from.name

	print("\n--- Changing scene from:", from.name, "to:", to_scene, "---")
	print("Before move → PlayerManager children:", PlayerManager.get_child_count())

	# Move all players to PlayerManager (preserve across scenes)
	for p in PlayerManager.players:
		if is_instance_valid(p):
			if p.get_parent() != PlayerManager:
				p.get_parent().remove_child(p)
				PlayerManager.add_child(p)
				p.owner = PlayerManager
	print("After move → PlayerManager children:", PlayerManager.get_child_count())

	var full_path = dir + to_scene + ".tscn"

	# ✅ Important: we call this function deferred, not the engine method
	call_deferred("_do_change_scene", full_path)


func _do_change_scene(full_path: String) -> void:
	print(">>> Doing scene change to:", full_path)
	get_tree().change_scene_to_file(full_path)

	# Wait one frame for scene to fully load
	await get_tree().process_frame

	var new_scene = get_tree().current_scene
	print("New current scene:", new_scene)

	if new_scene and new_scene.has_method("add_existing_players"):
		print("Calling add_existing_players() on:", new_scene)
		new_scene.add_existing_players(PlayerManager.players, last_scene_name)
	else:
		push_warning("⚠ New scene doesn't have add_existing_players()")

	#print("After attach → Scene children:", new_scene.get_child_count() if new_scene else "none")
	is_changing_scene = false
