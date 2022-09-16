extends VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_SettingsButton_pressed():
	visible = true
	pass # Replace with function body.


func _on_BackButton_pressed():
	visible = false
	pass # Replace with function body.
