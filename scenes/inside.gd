extends BaseScene

@onready var player1 = PlayerManager.active_player
@onready var player2 = PlayerManager.follower_player

func _ready():
	super()
	PlayerManager.set_players(player1,player2)
	PlayerManager.camera = camera
	
func _process(delta):
	PlayerManager.update_camera(delta)
	PlayerManager.update_animations(player1,player2)
	PlayerManager.update_follower(delta)
