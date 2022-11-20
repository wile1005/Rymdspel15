extends CanvasLayer

onready var game_over_timer = $Control/Game_over/Game_over_timer
onready var game_over = $Control/Game_over

func _ready() -> void:
	game_over.hide()

func _process(_delta: float) -> void:
	if Global.alive_players.size() <= 1 and get_tree().has_network_peer():
		if Global.alive_players[0].name == str(get_tree().get_network_unique_id()):
			game_over.show()
		
		if game_over_timer.time_left <= 0:
			game_over_timer.start()
