class_name sceneTrigger
extends Area2D

@export var connected_scene: String

func _on_body_entered(body: Node2D) -> void:
	print("Active:", PlayerManager.active_player)
	if body is Player and body == PlayerManager.active_player:
		sceneManager.change_scene(get_owner(), connected_scene)
