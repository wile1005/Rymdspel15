extends Node2D


func _ready() -> void:
	get_tree().connect("network_peer_disconnected",self ,"_player_disconnected")

func _player_disconnected(id) -> void:
	if Persistent_nodes.has_node(str(id)):
		Persistent_nodes.get_node(str(id)).username_text_instance.queue_free()
		Persistent_nodes.get_node(str(id)).queue_free()
