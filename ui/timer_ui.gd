extends Control
class_name TimerUI

@export var digit_textures: Array[Texture2D]

@onready var digits = {
	"H1": $H1,
	"H2": $H2,
	"M1": $M1,
	"M2": $M2,
	"S1": $S1,
	"S2": $S2,
	"MS1": $MS1,
	"MS2": $MS2
}

func _ready():
	GameTimer.connect("time_updated", Callable(self, "_on_time_updated"))
	GameTimer.connect("timer_stopped", Callable(self, "_on_timer_stopped"))

func _on_time_updated(time: float):
	#print(time)
	_update_display(time)

func _on_timer_stopped(final_time: float):
	print("Final time:", final_time)

func _update_display(elapsed_time: float):
	var total_ms = int(elapsed_time * 100) # hundredths of a second

	@warning_ignore("integer_division")
	var hours = int(total_ms / 360000)
	@warning_ignore("integer_division")
	var minutes = int((total_ms / 6000) % 60)
	@warning_ignore("integer_division")
	var seconds = int((total_ms / 100) % 60)
	var ms = int(total_ms % 100)
	
	
	@warning_ignore("integer_division")
	_set_digit("H1", int(hours / 10))
	_set_digit("H2", int(hours % 10))
	@warning_ignore("integer_division")
	_set_digit("M1", int(minutes / 10))
	_set_digit("M2", int(minutes % 10))
	@warning_ignore("integer_division")
	_set_digit("S1", int(seconds / 10))
	_set_digit("S2", int(seconds % 10))
	@warning_ignore("integer_division")
	_set_digit("MS1", int(ms / 10))
	_set_digit("MS2", int(ms % 10))

func _set_digit(digitName: String, value: int):
	if digitName in digits and value >= 0 and value < digit_textures.size():
		digits[digitName].texture = digit_textures[value]
