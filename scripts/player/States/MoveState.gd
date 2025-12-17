extends PlayerAbstractState
# ======  STATO DI MOVE DEL PLAYER  ====== #

@export var RUNNING_MULTYPLIER : float

# Reference al nodo che contiene le collision box per ruotarle
@onready var collisoin_boxes: Node2D = $"../../CollisoinBoxes"

func on_process(_delta: float) -> void:
	pass

# Qui viene effettivamente usata la funzione di fisica per calcolare lo spostamento
# E la direzione degli Sprite / Hitboxes
func on_physics_process(_delta: float) -> void:
	
	# Transizione allo stato di Falling se il player non è sul terreno
	if not player.is_on_floor():
		player.velocity.y += player.get_gravity().y * _delta
	
	# Se vale 0 si torna allo stato di Idle
	if player.inputs.direction == Direction.STILL:
		transition.emit(self, "Idle")
		return
	
	# Qui abbiamo un punto delicato, in base al tipo di evoluzione del dash
	# andiamo in uno stato o in un altro. 
	# NOTA: lo stato di TPQTE è uno speciale stato che viene chiamato solo se il blink
	# era un blink perfetto, ecco perchè qui non è presente la casistica
	if player.inputs.is_dash_buffered() and player.can_dash:
		print("Dash used in move: ", player.can_dash)
		match player.progressions.current_dash:
			player.progressions.DashType.DASH:
				transition.emit(self, "Dash") 
				return
			player.progressions.DashType.BLINK:
				transition.emit(self, "Blink")
				return
	
	# Se viene premuto il salto e non siamo sul pavimento controlliamo il coyote time
	# Se il coyote time non è disponibile allore non si fa nulla, se invece era disponibile si va in jump
	# Altrimenti se eravamo sul pavimento è una condizione sufficiente per saltare
	if player.inputs.is_jump_buffered() and (player.is_on_floor() or player.is_coyote_time_active()):
		transition.emit(self, "Jump")
		return
	
	# Con lo stesso criterio di ordine dello stato idle
	# Se si sta provando ad attaccare si cambia lo stato ad attack dopo gli stati aerei
	if player.inputs.is_attack_buffered():
		transition.emit(self, "Attack")
		return
	
	# Altrimenti viene applicato lo spostamento
	player.velocity.x = player.inputs.direction * player.MOVEMENT_SPEED
	
	# Rotazione degli sprite
	sprite.flip_h = true if player.last_direction == Direction.LEFT else false
	# Rotazione delle collisionboxes
	collisoin_boxes.scale.x = -1.0 if player.last_direction == Direction.LEFT else 1.0

	# Applicazione della fisica
	player.move_and_slide()
	



func enter() -> void:
	animator.play("walk")

func exit() -> void:
	pass
