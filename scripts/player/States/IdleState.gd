extends PlayerAbstractState
# ======  STATO DI IDLE DEL PLAYER  ====== #

# Nella funzione process vengono processati gli input del player
# Non vengono fatti calcoli fisici quindi siamo apposto
func on_process(_delta: float) -> void:
	
	# 1. Se siamo in idle ma non a terra allora andiamo allo stato di falling 
	if not player.is_on_floor():
		transition.emit(self, "Falling")
	
	# 2. Se siamo a terra e viene premuto il salto andiamo in jumping
	if player.inputs.is_jump_buffered():
		transition.emit(self, "Jump")
		return
	
	# 3. Dato che gli attacchi aerei sono gestiti internamente dagli stati aerei
	#    lo stato di attacco viene eseguito solo dopo di loro, ma prima dello stato di moving
	if player.inputs.is_attack_buffered():
		transition.emit(self, "Attack")
		return
	
	# 4. Stato di dash, gestito dopo anche lui
	# Qui abbiamo un punto delicato, in base al tipo di evoluzione del dash
	# andiamo in uno stato o in un altro. 
	# NOTA: lo stato di TPQTE è uno speciale stato che viene chiamato solo se il blink
	# era un blink perfetto, ecco perchè qui non è presente la casistica
	if player.inputs.is_dash_buffered() and player.can_dash:
		print("Dash used in idle: ", player.can_dash)
		match player.progressions.current_dash:
			player.progressions.DashType.DASH:
				transition.emit(self, "Dash") 
				return
			player.progressions.DashType.BLINK:
				transition.emit(self, "Blink")
				return
	
	# 5. Se direction è diversa da 0 allora viene fatta la transizione allo stato di Moving
	if player.inputs.direction != Direction.STILL:
		transition.emit(self, "Move")
		return

func on_physics_process(_delta: float) -> void:
	pass

func enter() -> void:
	animator.play("idle")

func exit() -> void:
	animator.stop()
