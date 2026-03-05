extends BaseScene


func _ready():
	MusicManager.play_music(preload("res://world/sound/Sonic 1 Music.wav"))
	GameTimer.stop()
