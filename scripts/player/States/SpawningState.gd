extends PlayerAbstractState
# ======  STATO DI SPAWNING DEL PLAYER  ====== #

func on_process(_delta: float) -> void:
	pass

# Lo stato di spawning applica la gravità e quando il player si trova sul terreno passa allo stato di idle
func on_physics_process(_delta: float) -> void:
	if not player.is_on_floor():
		player.velocity = player.get_gravity()
		player.move_and_slide()
	else:
		transition.emit(self, "idle")

func enter() -> void:
	animator.play("idle")

func exit() -> void:
	pass
