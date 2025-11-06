extends Node
class_name Commands

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		print("Restarting game…")
		call_deferred("_restart_game")

func _restart_game() -> void:
	var tree: SceneTree = get_tree()

	# Optional: manually reset singleton values
	PlayerManager.reset()

	# Go back to main scene
	var main_scene: String = ProjectSettings.get_setting("application/run/main_scene")
	tree.change_scene_to_file(main_scene)
