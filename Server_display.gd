extends Label

var ip_adress = ""

func _on_Join_button_pressed():
	Network.ip_address = ip_adress
	Network.join_server()
	get_parent().get_parent().queue_free()
