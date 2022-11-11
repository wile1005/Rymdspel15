extends KinematicBody2D

const speed = 200

var hp = 100 setget set_hp
var velocity = Vector2(0, 0)
var can_shoot = true
var is_reloading = false
var is_stunned = false

var bullet = load("res://Bullet.tscn")
var username_text = load("res://Username_text.tscn")

var username setget username_set
var username_text_instance = null

puppet var puppet_hp = 100 setget puppet_hp_set
puppet var puppet_position = Vector2(0, 0) setget puppet_position_set
puppet var puppet_velocity = Vector2()
puppet var puppet_rotation = 0
puppet var puppet_username = "" setget puppet_username_set

onready var tween = $Tween
onready var sprite = $Sprite
onready var reload_timer = $Reload_timer
onready var shoot_point = $Rotator/Shoot_point
onready var hit_timer = $Hit_timer

func _ready():
	get_tree().connect("network_peer_connected", self, "_network_peer_connected")
	
	username_text_instance = Global.instance_node_at_location(username_text, Persistent_nodes, global_position)
	username_text_instance.player_following = self
	
	update_shoot_mode(false)

func _process(delta: float) -> void:
	if username_text_instance != null:
		username_text_instance.name = "username" + name
	
	if is_network_master():
		var x_input = int(Input.is_action_pressed("Right")) - int(Input.is_action_pressed("Left"))
		var y_input = int(Input.is_action_pressed("Down")) - int(Input.is_action_pressed("Up"))
		
		if is_stunned == false:
			if Input.is_action_pressed("Down"):
				sprite.texture = load("res://Sprites/Player-down.png")
			elif(Input.is_action_pressed("Up")):
				sprite.texture = load("res://Sprites/Player-up.png")
			elif(Input.is_action_pressed("Right")):
				sprite.texture = load("res://Sprites/Player-right.png")
			elif(Input.is_action_pressed("Left")):
				sprite.texture = load("res://Sprites/Player-left.png")
		
		
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
	
	if hp <= 0:
		if username_text_instance != null:
			username_text_instance.visible = false
		
		if get_tree().is_network_server():
			rpc("destroy")

func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	
	tween.interpolate_property(self, "global_position", global_position, puppet_position, 0.1)
	tween.start()

#hp set sak
func set_hp(new_value):
	hp = new_value
	
	if is_network_master():
		rset("puppet_hp", hp)

func puppet_hp_set(new_value):
	puppet_hp = new_value
	
	if not is_network_master():
		hp = puppet_hp

func username_set(new_value) -> void:
	username = new_value
	
	if is_network_master() and username_text_instance != null:
		username_text_instance.text = username
		rset("puppet_username",username)

func puppet_username_set(new_value) -> void:
	puppet_username = new_value
	
	if not is_network_master() and username_text_instance != null:
		username_text_instance.text = puppet_username

func _network_peer_connected(id) -> void:
	rset_id(id, "puppet_username", username)

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
	

func update_shoot_mode(shoot_mode):
	if not shoot_mode:
		pass
	else:
		pass
	
	can_shoot = shoot_mode

func _on_Reload_timer_timeout():
	is_reloading = false

func _on_Hit_timer_timeout():
	is_stunned = false
	modulate = Color(1, 1, 1, 1)

func _on_Hitbox_area_entered(area):
	if get_tree().is_network_server():
		if area.is_in_group("Player_damager") and area.get_parent().player_owner != int(name):
			rpc("hit_by_damager", area.get_parent().damage)
			
			area.get_parent().rpc("destroy")

sync func hit_by_damager(damage):
	hp -= damage
	if $AnimationPlayer.is_playing():
		$AnimationPlayer.stop()
		$AnimationPlayer.play("Fallen")
	else:
		$AnimationPlayer.play("Falling")
	modulate = Color(5, 0, 0, 1)
	is_stunned = true
	hit_timer.start()

sync func destroy() -> void:
	update_shoot_mode(false)
	username_text_instance.visible = false
	if not is_network_master():
		visible = false
	$CollisionShape2D.disabled = true
	$Hitbox/CollisionShape2D.disabled = true
