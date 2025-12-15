extends AbstractState

func enter():
	animator.play("parried")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "parried":
		transition.emit(self, "idle")
