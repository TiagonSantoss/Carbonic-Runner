extends BaseScene

@onready var player1 = PlayerManager.active_player
@onready var player2 = PlayerManager.follower_player

func _ready():
	super()
	await get_tree().process_frame
	#PlayerManager.set_players(player1,player2)
	PlayerManager.camera = camera
	MusicManager.play_music(preload("res://world/sound/Broken Smoke Machine.wav"))
	#await get_tree().create_timer(0.1).timeout
	#GameTimer.stop()
	
func _process(delta):
	PlayerManager.update_camera(delta)
	PlayerManager.update_animations(player1,player2)
	PlayerManager.update_follower(delta)
