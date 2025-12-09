extends Area2D


func _on_body_entered(body: Node2D) -> void:
	print("Body entered")
	if body is Player:
		print("Player intercettato")
