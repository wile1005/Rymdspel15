extends VBoxContainer

onready var multiplayer_config_ui = $Multiplayer_configure
onready var server_ip_adress = $Multiplayer_configure/server_ip_adress

onready var device_ip_adress = $Multiplayer_configure/Devic_ip_adress

func _ready() -> void:
	visible = false
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connect_to_server")
	
	device_ip_adress.text = Network.ip_adress

func _player_conncted(id) -> void:
	print("Player " + str(id) + " has connected")

func _player_disconnected(id) -> void:
	print("Player " + str(id) + " has disconnected")



func _on_Create_server_pressed():
	multiplayer_config_ui.hide()
	Network.create_server()


func _on_Join_server_pressed():
	if server_ip_adress.text != "":
		multiplayer_config_ui.hide()
		Network.ip_adress = server_ip_adress.text
		Network.join_server()
	pass


func _on_MultiplayerButton_pressed():
	visible = true
	pass


func _on_BackButton_pressed():
	visible = false
	pass 

