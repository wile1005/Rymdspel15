extends Node

const DEFAULT_PORT = 2896
const MAX_CLIENTS = 6

var server = null
var client = null

var ip_adress = ""

func _ready():
	if OS.get_name() == "Windows":
		ip_adress = IP.get_local_addresses()[3]
	elif OS.get_name() == "Android":
		ip_adress = IP.get_local_addresses()[0]
	else:
		ip_adress = IP.get_local_addresses()[3]
	
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.126."):
			ip_adress = ip
	
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func create_server() -> void:
	server = NetworkedMultiplayerENet.new()
	server.create_server(DEFAULT_PORT, MAX_CLIENTS)
	get_tree().set_network_peer(server)

func join_server() -> void:
	server = NetworkedMultiplayerENet.new()
	server.create_client(ip_adress, DEFAULT_PORT)
	get_tree().set_network_peer(client)

func _connected_to_server() -> void:
	print("Succsesfully connected to server")

func _server_disconnected() -> void:
	print("Disconnected from the server")
