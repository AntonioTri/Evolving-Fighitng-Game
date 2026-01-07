extends PlayerAbstractState
# ====== STATO DI JUMP DEL PLAYER ====== #

var jump_velocity : float = 0.0
var jump_gravity : float = 0.0
var fall_gravity : float = 0.0
var time_in_state: float = 0.0 # Contatore del tempo
var short_hop_active: bool = false # Flag per gravità aumentata
@onready var landing_raycast: RayCast2D = $"../../PlayerVisuals/LandingRaycast"

func enter() -> void:
	
	player.inputs.consume_jump() # Consumiamo il salto
	time_in_state = 0.0
	short_hop_active = false
	
	# Solo se il player non è a terra, usiamo il jump_velocity normale.
	# Questo perché l'input bufferizzato potrebbe essere stato catturato anche 
	# in aria, ma vogliamo fare il salto solo se siamo a terra o in Coyote Time.
	if player.is_on_floor() or player.is_coyote_time_active(): jump() 
	# Se l'input è arrivato in aria, ma non possiamo saltare, 
	# usciamo immediatamente dallo stato ( torniamo a falling )
	else: transition.emit(self, "Falling") 


func on_physics_process(_delta: float) -> void:
	
	# Controllo sul dash, prioritario
	if player.inputs.is_dash_buffered() and player.can_dash:
		match player.progressions.current_dash:
			player.progressions.DashType.DASH:
				transition.emit(self, "Dash") 
				return
			player.progressions.DashType.BLINK:
				transition.emit(self, "Blink")
				return
	
	time_in_state += _delta # Aggiorna il tempo

	# Salto ad altezza variabile
	var jump_released = not Input.is_action_pressed("jump")
	
	# Logica per l'interruzione anticipata (Short Hop)
	if player.velocity.y < 0 and time_in_state > player.min_jump_duration:
		# Se il player sta ancora salendo E ha superato il tempo minimo
		if jump_released and not short_hop_active:
			# Se il tasto è stato rilasciato, attiva la gravità extra
			short_hop_active = true
	
	player.velocity.y += get_gravity() * _delta
	player.velocity.x = get_input_velocity() * player.MOVEMENT_SPEED
	
	# Animazione e direzione
	# Assumo che 'sprite' sia una variabile di riferimento definita nella classe base o nel Player
	# Se 'sprite' non è definito qui, usa player.visuals.flip_h o la tua struttura specifica
	
	sprite.flip_h = true if player.last_direction == Direction.LEFT else false
	do_jump_animation()
	
	# Transizione ad idle se il player tocca terra
	if player.is_on_floor() and player.velocity.y > 0: transition.emit(self, "Idle")
	
	player.move_and_slide()


func get_gravity() -> float:
	# Se è stato innescato il "salto corto" O se sta già cadendo
	if short_hop_active or player.velocity.y >= 0.0:
		return fall_gravity
	else:
		# Altrimenti, usa la gravità normale di salita
		return jump_gravity
		

func exit() -> void:
	pass

func jump():
	player.velocity.y = jump_velocity

# La funzione che aiuta a scegliere la direzione durante il salto
func get_input_velocity() -> float: # Cambiato in float per consistenza con Vector2.x
	# Usa la direzione calcolata dal PlayerInputComponent
	return player.inputs.direction

# Il Player lo chiamerà dopo aver caricato tutto.
func initialize_physics_constants():
	# Usiamo le variabili del Player ora che sappiamo che il riferimento è valido
	jump_velocity = (( 2.0 * player.jump_height ) / player.jump_time_to_peak ) * -1
	jump_gravity = (( -2.0 * player.jump_height ) / ( player.jump_time_to_peak * player.jump_time_to_peak )) * -1
	fall_gravity = (( -2.0 * player.jump_height ) / ( player.jump_time_to_descend * player.jump_time_to_descend )) * -1

# con questa funzione viene riprodotta una animazione di salto in salita 
# ed in discesa in base alla velocità verticale del player
func do_jump_animation():
	# CONTROLLO ATTERRAGGIO
	if landing_raycast.is_colliding() and player.velocity.y > 80:
		if animator.current_animation != "landing":
			animator.play("landing")
	
	elif (player.velocity.y >= -80) and (player.velocity.y <= 80):
		if animator.current_animation != "hovering_in_air":
			animator.play("hovering_in_air")
	
	elif player.velocity.y < -80:
		if animator.current_animation != "jump_up":
			animator.play("jump_up")
	
	elif player.velocity.y > 80:
		if animator.current_animation != "jump_down":
			animator.play("jump_down")
