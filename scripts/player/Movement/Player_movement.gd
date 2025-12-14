# PlayerMovement.gd
extends Node
class_name PlayerMovement

# Variabili esportate per la gestione del movimento
@export var speed := 200.0
@export var run_multiplier := 1.5
@export var jump_velocity := 400.0
@export var FALLING_SPEED_MULTIPLIER := 1.2

# Riferimento al player per accedere alle sue variabili
@onready var player: Player = $".."


# La funzione update gestisce l'update non fisico del movimento del player
func update(_delta):
	pass


# La funzione physics_update gestisce il movimento del player in base agli input letti
func physics_update(_delta):

	if not player.is_on_floor():
		apply_gravity(_delta)

	if player.states.can_move():
		move()
		handle_jump()


# La funzione move gestisce il movimento orizzontale del player
func move():

	# Calcolo della velocità in base al fatto che il player stia correndo o camminando
	var final_speed = speed

	if player.inputs.run_pressed and player.inputs.direction != Direction.STILL:
		# Se il tasto di corsa è premuto, moltiplica la velocità per il moltiplicatore di corsa
		final_speed *= run_multiplier
		# Imposta lo stato di corsa nel StateManager
		player.states.set_running()
	
	elif player.inputs.direction != Direction.STILL:
		# Imposta lo stato di camminata nel StateManager
		player.states.set_walking()

	elif player.inputs.direction == Direction.STILL:
		# Imposta lo stato di fermo nel StateManager
		player.states.stop_movement()

	# Aggiorna la velocità orizzontale del player
	player.velocity.x = player.inputs.direction * final_speed
	player.move_and_slide()


# La funzione handle_jump gestisce il salto del player
func handle_jump():
	if player.inputs.jump_pressed:
		jump()

# La funzione jump fa saltare il player aggiungendo una velocità verticale negativa
func jump():
	if player.is_on_floor():
		player.velocity.y = -jump_velocity


# La funzione apply_gravity applica la gravità al player
# Quando il player sta scendendo la velocità verticale aumenta
func apply_gravity(delta):
	if not player.is_on_floor():
		# Gestione normale della gravità
		if player.velocity.y <= 0:
			player.velocity += player.get_gravity() * delta
		# Gestione della caduta più veloce
		else:
			player.velocity += player.get_gravity() * delta * FALLING_SPEED_MULTIPLIER
