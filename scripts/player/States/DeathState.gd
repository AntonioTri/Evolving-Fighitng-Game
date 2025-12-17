extends AbstractState

# Viene fatta partire l'animazione di attacco
func enter() -> void:
	print("Player died")
	owner_body.queue_free()

# Quando l'animazione di morte finisce il segnale viene catturato ed il nemico viene
# rimosso dalla scena
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "die":
		owner_body.queue_free()
