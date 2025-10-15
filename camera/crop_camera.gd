extends Area2D

@export var crop_radius = 1000
var camera: Camera2D

func _on_body_entered(body: Node2D) -> void:
	if body.get_node("Camera2D"):
		camera = body.get_node("Camera2D")
		camera.limit_bottom -= crop_radius
		camera.limit_top += int(-1.2*crop_radius)
		camera.limit_left -= int(1.6*crop_radius)
		camera.zoom = Vector2(1.0,1.0)
		queue_free()
