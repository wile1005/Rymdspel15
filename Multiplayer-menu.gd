extends Control

var player = load("res://Player.tscn")

var current_spawn_location_instance_number = 1
var current_player_for_spawn_location_number = null

onready var multiplayer_config_ui = $Multiplayer_configure
onready var username_text_edit = $Multiplayer_configure/Username_text_edit

onready var device_ip_address = $Ui/Devic_ip_adress
onready var start_game = $Ui/Start_game

func _ready() -> void:
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	
	device_ip_address.text = Network.ip_address
	
	if get_tree().network_peer != null:
		multiplayer_config_ui.hide()
		for player in Persistent_nodes.get_children():
			if player.is_in_group("Player"):
				for spawn_location in $Spawn_Locations.get_children():
					if int(spawn_location.name) == current_spawn_location_instance_number and current_player_for_spawn_location_number != player:
						player.rpc("update_position", spawn_location.global_position)
						player.rpc("enable")
						current_spawn_location_instance_number += 1
						current_player_for_spawn_location_number = player
	else:
		start_game.hide()

func _process(delta):
	if get_tree().network_peer != null:
		if get_tree().get_network_connected_peers().size() >= 1 and get_tree().is_network_server():
			start_game.show()
		else:
			start_game.hide()

func _player_connected(id) -> void:
	print("Player " + str(id) + " has connected")
	
	instance_player(id)

func _player_disconnected(id) -> void:
	print("Player " + str(id) + " has disconnected")
	
	if Persistent_nodes.has_node(str(id)):
		Persistent_nodes.get_node(str(id)).username_text_instance.queue_free()
		Persistent_nodes.get_node(str(id)).queue_free()

func _on_Create_server_pressed():
	if username_text_edit.text != "":
		Network.current_player_username = username_text_edit
		multiplayer_config_ui.hide()
		Network.create_server()
	
		instance_player(get_tree().get_network_unique_id())

func _on_Join_server_pressed():
	if username_text_edit.text != "":
		multiplayer_config_ui.hide()
		username_text_edit.hide()
		
		Global.instance_node(load("res://Server_browser.tscn"), self)


func _connected_to_server() -> void:
	print("joined")
	yield(get_tree().create_timer(0.1), "timeout")
	instance_player(get_tree().get_network_unique_id())

func instance_player(id) -> void:
	var player_instance = Global.instance_node_at_location(player, Persistent_nodes, Vector2(rand_range(0, 1920), rand_range(0,1080)))
	player_instance.name = str(id)
	player_instance.set_network_master(id)
	player_instance.username = username_text_edit.text


func _on_MultiplayerButton_pressed():
	visible = true
	pass


func _on_BackButton_pressed():
	visible = false
	pass 

func _on_Start_game_pressed():
	rpc("switch_to_game")



sync func switch_to_game() -> void:
	for child in Persistent_nodes.get_children():
		if child.is_in_group("Player"):
			child.update_shoot_mode(true)
			child.game_start()
	
	$Ui/Devic_ip_adress.visible=false
	
	get_tree().change_scene("res://Game.tscn")


func _on_Button_pressed():
	get_tree().quit()
