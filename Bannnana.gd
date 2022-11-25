extends Sprite

export(int) var damage = 0


var player_owner = 0


func _on_CollisionShape2D_enter(body):
	rpc("destroy")

sync func destroy() -> void:
	queue_free()
