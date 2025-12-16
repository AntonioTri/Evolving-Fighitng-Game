extends PlayerAbstractState
class_name AirState

@export var FALLING_MOVEMENT_MULTIPLIER : float = 0.7

func on_physics_process(_delta: float) -> void:
	# 1. Applicazione corretta della gravità
	player.velocity.y += player.get_gravity().y * _delta
	
	# 2. Controllo del movimento orizzontale in aria (ridotto con uno scalare costante)
	player.velocity.x = player.inputs.direction * player.MOVEMENT_SPEED * FALLING_MOVEMENT_MULTIPLIER
	
	# 3. Transizione al salto se il salto aereo o quello doppio è stato sbloccato
	if player.progressions.current_jump == player.progressions.JumpType.DOUBLE_JUMP:
		if player.inputs.is_jump_buffered():
			transition.emit(self, "Jump")
			return
	
	# 4. Transizione all'Atterraggio
	if player.is_on_floor():
		if player.inputs.direction != Direction.STILL:
			transition.emit(self, "Move") # o "Move" a seconda dell'input
		elif player.inputs.direction == Direction.STILL:
			transition.emit(self, "Idle")
	
	player.move_and_slide()

func enter() -> void:
	animator.play("idle")
