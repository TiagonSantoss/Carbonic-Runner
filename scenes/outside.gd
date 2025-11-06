extends BaseScene


func _ready():
	super()
	PlayerManager.set_players(PlayerManager.active_player,PlayerManager.follower_player)
	PlayerManager.camera = camera
	GameTimer.start()
	MusicManager.play_music(preload("res://world/sound/level.wav"))
	
	
func _process(delta):
	PlayerManager.update_camera(delta)
	PlayerManager.update_animations(PlayerManager.active_player,PlayerManager.follower_player)
	PlayerManager.update_follower(delta)
