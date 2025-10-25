extends Node
class_name Game_Timer

var elapsed_time: float = 0.0
var running: bool = false

signal time_updated(elapsed_time: float)
signal timer_stopped(final_time: float)

func _process(delta: float) -> void:
	if running:
		elapsed_time += delta
		time_updated.emit(elapsed_time)
		#print(elapsed_time)

func start() -> void:
	if not running:
		running = true

func stop() -> void:
	if running:
		running = false
		timer_stopped.emit(elapsed_time)

func reset() -> void:
	elapsed_time = 0.0
	time_updated.emit(elapsed_time)

func get_time() -> float:
	return elapsed_time
