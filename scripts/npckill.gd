extends Area2D

func _on_npckill_body_entered(body: Node2D) -> void:
	# Because we are using "body" right here, the warning will disappear
	if "NPCCar" in body.name:
		body.queue_free()
