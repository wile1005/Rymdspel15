extends CheckButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_FullscreenButton_toggled(button_pressed):
	if button_pressed == true:
		OS.window_fullscreen = true
	elif button_pressed == false:
		OS.window_fullscreen = false
	pass # Replace with function body.






