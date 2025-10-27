extends BaseScene

@onready var player1 = $player1
@onready var player2 = $player2

func _ready():
	super()
	PlayerManager.set_players(player1,player2)
	PlayerManager.camera = camera
	GameTimer.start()
	MusicManager.play_music(preload("res://world/sound/level.wav"))
	
func _process(delta):
	PlayerManager.update_camera(delta)
	PlayerManager.update_animations(player1,player2)
	PlayerManager.update_follower(delta)
