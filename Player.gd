extends KinematicBody2D

const speed = 400

var velocity = Vector2(0, 0)

puppet var puppet_position = Vector2(0, 0) setget puppet_position_set
puppet var puppet_velocity = Vector2()
onready var tween = $Tween

func _process(delta: float) -> void:
	if is_network_master():
		var x_input = int(Input.is_action_pressed("Right")) - int(Input.is_action_pressed("Left"))
		var y_input = int(Input.is_action_pressed("Down")) - int(Input.is_action_pressed("Up"))
		
		velocity = Vector2(x_input, y_input).normalized()
		
		move_and_slide(velocity * speed)
		
		$Camera2D.current=true
	else:
		
		if not tween.is_active():
			move_and_slide(puppet_velocity * speed)

func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	
	tween.interpolate_property(self, "global_position", global_position, puppet_position, 0.1)
	tween.start()

func _on_Network_tick_rate_timeout():
	if is_network_master():
		rset_unreliable("puppet_position", global_position)
		rset_unreliable("puppet_velocity", velocity)
