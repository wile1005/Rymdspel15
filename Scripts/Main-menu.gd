extends CanvasLayer


func _ready():
	$Main_menu.visible = true
	$Settings_menu.visible = false
	$Multiplayer_menu.visible = false
	$ColorRect.visible = true
	pass 

func _on_ExitButton_pressed():
	get_tree().quit()
	pass # Replace with function body.


func _on_SettingsButton_pressed():
	$Main_menu.visible = false
	$Settings_menu.visible = true
	$Multiplayer_menu.visible = false
	pass # Replace with function body.


func _on_MultiplayerButton_pressed():
	$Main_menu.visible = false
	$Settings_menu.visible = false
	$Multiplayer_menu.visible = true
	pass # Replace with function body.


func _on_BackButton_pressed():
	$Main_menu.visible = true
	$Settings_menu.visible = false
	$Multiplayer_menu.visible = false
	pass # Replace with function body.


func _on_Create_server_pressed():
	$Main_menu.visible = false
	$Settings_menu.visible = false
	$Multiplayer_menu.visible = false
	$ColorRect.visible = false
	pass # Replace with function body.


func _on_Join_server_pressed():
	$ColorRect.visible = false
	pass # Replace with function body.
