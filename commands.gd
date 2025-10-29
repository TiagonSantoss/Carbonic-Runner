extends Node
class_name Commands

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		print("reloaded")
		call_deferred("_reload_scene")

func _reload_scene() -> void:
	get_tree().reload_current_scene()
