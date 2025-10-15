extends Area2D

@export var crop_radius = 5000
var camera: Camera2D

func _on_body_entered(body: Node2D) -> void:
	if body.get_node("Camera2D"):
		camera = body.get_node("Camera2D")
		camera.limit_left = int(1.6*crop_radius)
		camera.limit_top = int(-0.9*crop_radius)
		camera.zoom = Vector2(0.6,0.6)
		queue_free()
