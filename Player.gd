extends KinematicBody2D

const speed = 200

var hp = 100 setget set_hp
var velocity = Vector2(0, 0)
var can_shoot = true
var is_reloading = false
var is_stunned = false
var texture_offset = 1

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
onready var escape_menu = $Ui/Escape_menu
onready var game_ui = $Ui/Game_ui

func _ready():
	get_tree().connect("network_peer_connected", self, "_network_peer_connected")
	
	username_text_instance = Global.instance_node_at_location(username_text, Persistent_nodes, global_position)
	username_text_instance.player_following = self
	
	escape_menu.visible = false
	game_ui.visible = false
	
	update_shoot_mode(false)
	Global.alive_players.append(self)
	
	yield(get_tree(), "idle_frame")
	if get_tree().has_network_peer():
		if is_network_master():
			Global.player_master = self

func _process(delta: float) -> void:
	if username_text_instance != null:
		username_text_instance.name = "username" + name
	
	if get_tree().has_network_peer():
		if is_network_master():
			
			if Input.is_action_just_pressed("Escape") and escape_menu.visible == false:
				escape_menu.visible = true
				is_stunned = true
				can_shoot = false
			elif Input.is_action_just_pressed("Escape") and escape_menu.visible == true:
				escape_menu.visible = false
				is_stunned = false
				can_shoot = true
			
			if is_stunned == false:
				var x_input = int(Input.is_action_pressed("Right")) - int(Input.is_action_pressed("Left"))
				var y_input = int(Input.is_action_pressed("Down")) - int(Input.is_action_pressed("Up"))
				velocity = Vector2(x_input, y_input).normalized()
				
				if Input.is_action_pressed("Down"):
					sprite.region_rect = Rect2( 0+texture_offset, 0, 32, 32)
				elif(Input.is_action_pressed("Up")):
					sprite.region_rect = Rect2( 32+texture_offset, 32, 32, 32)
				elif(Input.is_action_pressed("Right")):
					sprite.region_rect = Rect2( 32+texture_offset, 0, 32, 32)
				elif(Input.is_action_pressed("Left")):
					sprite.region_rect = Rect2( 0+texture_offset, 32, 32, 32)
			
			$Camera2D.current = true
			
			move_and_slide(velocity * speed)
			
			$Rotator.look_at(get_global_mouse_position())
			
			if Input.is_action_pressed("click") and can_shoot and not is_reloading:
				rpc("instance_bullet", get_tree().get_network_unique_id())
				is_reloading = true
				reload_timer.start()
			
		else:
			$Rotator.rotation_degrees = lerp($Rotator.rotation_degrees, puppet_rotation, delta * 8)
			
			
			
			if not tween.is_active():
				move_and_slide(puppet_velocity * speed)
	
	if hp <= 0:
		if username_text_instance != null:
			username_text_instance.visible = false
		if get_tree().has_network_peer():
			if get_tree().is_network_server():
				rpc("destroy")

func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	
	tween.interpolate_property(self, "global_position", global_position, puppet_position, 0.1)
	tween.start()

#hp set sak
func set_hp(new_value):
	hp = new_value
	
	if get_tree().has_network_peer():
		if is_network_master():
			rset("puppet_hp", hp)

func puppet_hp_set(new_value):
	puppet_hp = new_value
	
	if get_tree().has_network_peer():
		if not is_network_master():
			hp = puppet_hp

func username_set(new_value) -> void:
	username = new_value
	
	if get_tree().has_network_peer():
		if is_network_master() and username_text_instance != null:
			username_text_instance.text = username
			rset("puppet_username",username)

func puppet_username_set(new_value) -> void:
	puppet_username = new_value
	
	if get_tree().has_network_peer():
		if not is_network_master() and username_text_instance != null:
			username_text_instance.text = puppet_username

func game_start() -> void:
	if get_tree().has_network_peer():
		if is_network_master():
			game_ui.visible = true

func _network_peer_connected(id) -> void:
	rset_id(id, "puppet_username", username)

func _on_Network_tick_rate_timeout():
	if get_tree().has_network_peer():
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

sync func update_position(pos):
	global_position = pos
	puppet_position = pos

func update_shoot_mode(shoot_mode):
	if not shoot_mode:
		pass
	else:
		pass
	
	can_shoot = shoot_mode

func _on_Reload_timer_timeout():
	is_reloading = false

func _on_Hit_timer_timeout():
	modulate = Color(1, 1, 1, 1)
	yield(get_tree().create_timer(1.0), "timeout")
	is_stunned = false

func _on_Hitbox_area_entered(area):
	if get_tree().has_network_peer():
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

sync func enable() -> void:
	hp = 100
	can_shoot = false
	is_stunned = false
	modulate.a = 1
	update_shoot_mode(false)
	username_text_instance.visible = true
	visible = true
	$CollisionShape2D.disabled = false
	$Hitbox/CollisionShape2D.disabled = false
	texture_offset = 0
	sprite.region_rect = Rect2( 0+texture_offset, 0, 32, 32)
	$AnimationPlayer.play("Clear")
	if get_tree().has_network_peer():
		if is_network_master():
			Global.player_master = self
	
	if not Global.alive_players.has(self):
		Global.alive_players.append(self)

sync func destroy() -> void:
	can_shoot = false
	is_stunned = false
	modulate.a = 0.5
	texture_offset = 64
	sprite.region_rect = Rect2( 0+texture_offset, 0, 32, 32)
	update_shoot_mode(false)
	username_text_instance.visible = false
	$AnimationPlayer.play("Clear")
	Global.alive_players.erase(self)
	if escape_menu.visible == true:
		is_stunned = true
	if get_tree().has_network_peer():
		if not is_network_master():
			visible = false
			Global.player_master = null
		else:
			game_ui.visible = false
	$CollisionShape2D.disabled = true
	$Hitbox/CollisionShape2D.disabled = true
	
	if get_tree().has_network_peer():
		if is_network_master():
			Global.player_master = null

func _exit_tree() -> void:
	Global.alive_players.erase(self)
	if get_tree().has_network_peer():
		if is_network_master():
			Global.player_master = null


func _on_Backtogame_pressed():
	escape_menu.visible = false
	is_stunned = false

func _on_Exit_pressed():
	get_tree().quit()
