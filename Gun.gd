extends Sprite

var item = "gun"

func _on_CollisionShape2D_enter(body):
	rpc("destroy")

sync func destroy() -> void:
	queue_free()

