extends Control

onready var server_listner = $Server_lister
onready var server_ip_text_edit = $Background_panel/Server_ip_text_edit
onready var server_container = $Background_panel/VBoxContainer
onready var manual_setup_button = $Background_panel/Manual_setup

func _ready() -> void:
	server_ip_text_edit.hide()


func _on_Server_lister_new_server():
	pass # Replace with function body.


func _on_Server_lister_remove_server():
	pass # Replace with function body.
