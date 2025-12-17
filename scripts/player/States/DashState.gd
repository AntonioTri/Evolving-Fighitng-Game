extends PlayerAbstractState
# ====== STATO DI DASH DEL PLAYER ====== #

# Varibili di dati interne
var dash_duration: float = 0.0
var time_elapsed: float = 0.0
var dash_direction: int = 1

func enter() -> void:
	
	# Consumiamo l'input
	player.inputs.consume_dash()
	
	# 1. CONTROLLO EVOLUZIONE (Progression)
	# Controlliamo se dobbiamo eseguire un Blink invece del Dash normale
	if player.progressions.dash_evolved and is_dash_perfect():
		transition.emit(self, "Blink") 
		return
	
	# 2. SETUP DEL DASH FISICO
	# Calcoliamo quanto deve durare il dash: Tempo = Spazio / Velocità
	dash_duration = player.dash_distance / player.dash_speed
	time_elapsed = 0.0
	
	# Determiniamo la direzione (basata sull'input o sull'ultima direzione)
	# Se il player sta premendo una direzione, dasha lì, altrimenti dasha dove guarda.
	var input_x = player.inputs.direction
	if input_x != 0:
		dash_direction = sign(input_x)
	else:
		# Scelta della direzione del dash in base alla direzine attuale del giocatore
		dash_direction = 1 if player.last_direction == Direction.RIGHT else -1
	
	# Setup Animazione
	# player.animator.play("roll") 
	
	# Disabilitiamo collisioni con nemici? (Opzionale: I-Frames)
	# player.hurtbox.monitorable = false 


func on_physics_process(delta: float) -> void:
	time_elapsed += delta
	
	# 1. APPLICAZIONE VELOCITÀ 
	if not player.is_on_floor(): player.velocity.y += player.jump_dash_falling_speed
	player.velocity.x = dash_direction * player.dash_speed
	
	# 2. GESTIONE COLLISIONI MURI
	# Se colpisco un muro, il dash finisce immediatamente
	if player.is_on_wall() or time_elapsed >= dash_duration:
		_finish_dash()
		return
	
	# 3. MOVIMENTO
	player.move_and_slide()


func _finish_dash():
	# Resetta velocità orizzontale per evitare scivolamenti indesiderati
	player.velocity.x = 0 
	
	# Avvia il cooldown
	player.can_dash = false
	
	# DECISIONE DELLO STATO SUCCESSIVO
	if player.is_on_floor():
		# Se c'è input di movimento, vai a Move, altrimenti Idle
		if player.inputs.direction != 0:
			transition.emit(self, "Move")
		else:
			transition.emit(self, "Idle")
	else:
		# Se siamo finiti in aria (es. dashato giù da un burrone), cadiamo
		transition.emit(self, "Falling")


func on_process(_delta: float) -> void:
	# Gestione Cooldown (funziona anche quando non siamo in questo stato se lo script è attivo,
	# ma negli FSM solitamente lo script non 'processa' se non è attivo.
	# Quindi il cooldown va gestito meglio nel Player o con un Timer esterno.
	pass


func exit() -> void:
	# Riabilita collisioni/hurtbox se disabilitate
	# player.hurtbox.monitorable = true
	
	pass


# Attualmente la funzione ritorna sempre false in quando non è implementata la logica
# di dash perfetto o di blink perfetto
func is_dash_perfect() -> bool:
	return false
	
