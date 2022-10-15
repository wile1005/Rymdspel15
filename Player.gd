extends KinematicBody2D

const speed = 200

var velocity = Vector2(0, 0)
var can_shoot = true
var is_reloading = false

var bullet = load("res://Bullet.tscn")

puppet var puppet_position = Vector2(0, 0) setget puppet_position_set
puppet var puppet_velocity = Vector2()
puppet var puppet_rotation = 0

onready var tween = $Tween
onready var sprite = $Sprite
onready var reload_timer = $Reload_timer
onready var shoot_point = $Rotator/Shoot_point

func _process(delta: float) -> void:
	if is_network_master():
		var x_input = int(Input.is_action_pressed("Right")) - int(Input.is_action_pressed("Left"))
		var y_input = int(Input.is_action_pressed("Down")) - int(Input.is_action_pressed("Up"))
		
		velocity = Vector2(x_input, y_input).normalized()
		
		move_and_slide(velocity * speed)
		
		$Rotator.look_at(get_global_mouse_position())
		
		if Input.is_action_pressed("click") and can_shoot and not is_reloading:
			rpc("instance_bullet", get_tree().get_network_unique_id())
			is_reloading = true
			reload_timer.start()
		
		$Camera2D.current=true
	else:
		$Rotator.rotation_degrees = lerp($Rotator.rotation_degrees, puppet_rotation, delta * 8)
		
		if not tween.is_active():
			move_and_slide(puppet_velocity * speed)

func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	
	tween.interpolate_property(self, "global_position", global_position, puppet_position, 0.1)
	tween.start()

func _on_Network_tick_rate_timeout():
	if is_network_master():
		rset_unreliable("puppet_position", global_position)
		rset_unreliable("puppet_rotation", rotation_degrees)
		rset_unreliable("puppet_velocity", velocity)

sync func instance_bullet(id):
	var bullet_instance = Global.instance_node_at_location(bullet, Persistent_nodes, shoot_point.global_position)
	bullet_instance.name = "Bullet" + name + str(Network.networked_object_name_index)
	bullet_instance.set_network_master(id)
	bullet_instance.player_rotation = $Rotator.rotation
	bullet_instance.player_owner = id
	Network.networked_object_name_index += 1
	

func _on_Reload_timer_timeout():
	is_reloading = false
