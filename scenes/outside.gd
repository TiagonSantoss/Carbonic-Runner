extends BaseScene

@onready var player1 = $player1
@onready var player2 = $player2
@onready var camera = $Camera2D

func _ready():
	super()
	PlayerManager.set_players(player1,player2)
	PlayerManager.camera = camera
	
func _process(delta):
	PlayerManager.update_follower(delta)
	PlayerManager.update_camera(delta)
