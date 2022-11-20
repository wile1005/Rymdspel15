extends Control

export var bootsplash_toggle = true

func _ready():
	if bootsplash_toggle == true:
		yield(get_tree().create_timer(1.0), "timeout")
		$Label/AnimationPlayer.play("boot_text")
		yield(get_tree().create_timer(2.5), "timeout")
		$AudioStreamPlayer.volume_db = -20
		$AudioStreamPlayer.play()
		yield(get_tree().create_timer(1.5), "timeout")
		get_tree().change_scene("res://Network_setup.tscn")
	else:
		get_tree().change_scene("res://Network_setup.tscn")
