extends PlayerAbstractState


func enter():
	
	# Riproduci un'animazione di default (es. Idle o una posa statica)
	if animator:
		animator.play("idle") 
	
	# Creiamo un timer "one-shot" tramite il SceneTree
	# timeout è il segnale emesso allo scadere del tempo
	await get_tree().create_timer(1.0).timeout
	transition.emit(self, "Idle")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "stunned":
		transition.emit(self, "idle")
