extends AbstractState

func enter():
	animator.play("stunned")
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "stunned":
		transition.emit(self, "idle")
