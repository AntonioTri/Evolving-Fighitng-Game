extends Node
class_name PlayerFineteStateMahcine

@export var player : Player
@export var sprite : Sprite2D
@export var animator : AnimationPlayer
@export var starting_state : PlayerAbstractState


var states : Dictionary = {}
var current_state : AbstractState


func _ready() -> void:
	
	for child in get_children(): initialize_child(child)

	# Se presente viene impostato uno stato di partenza
	if starting_state:
		starting_state.enter()
		current_state = starting_state
	
	# Associazione dei segnali di stato atomici provenienti dal nemico proprietario
	attach_signals()


# La funzione process chiama la process dello stato corrente
func _process(delta: float) -> void:
	if current_state:
		current_state.on_process(delta)

# La funzione physics process chiama la relativa funzine delo stato corrente
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.on_physics_process(delta)

# Questa funzine collegata al segnale interno degli stati, cambia lo stato corrente con quello in input
func change_state(old_state : PlayerAbstractState, new_state_name: String) -> void:
	
	# Se il vecchio stato e quello attuale non matchano viene catturato il bug
	if current_state != old_state:
		print("Player Bug found, old state and current state are not matching")
		print(old_state.name)
		print(current_state.name)
		return
	
	# Caso in cui lo stato sia lo stesso
	if new_state_name == current_state.name.to_lower():
		print("Player alredy in the " + current_state.name.to_lower() + " state.")
		return
	
	# Viene estratto lo stato dal dizionario
	var new_state = states.get(new_state_name.to_lower())
	
	# Handling degli errori
	if not new_state:
		return
	
	# Se lo stato è stato trovato quello corrente viene spento
	if current_state:
		current_state.exit()
	
	# Viene attivato quello nuovo e vengono settate le giuste referenze allos tato corrente
	new_state.enter()
	print("State machine: changing PLAYER state to ", new_state_name)
	current_state = new_state



func initialize_child(child):
	# Per ogni stato interno alla state machine vengon assegnate le referenze a:
	# 1. funzione di transizione
	# 2. Entità proprietaria
	# 3. Sprite2D proprietario
	# 4. AniamtorPlayer proprietario
	states[child.name.to_lower()] = child
	child.transition.connect(change_state)
	child.sprite = sprite
	child.animator = animator
	
	if child is PlayerAbstractState:
		child.player = player
	
	elif child is AbstractState:
		child.owner_body = player

# Associazione dei segnali di stato atomici provenienti dal nemico proprietario
func attach_signals():
	player.died.connect(_on_player_died)
	player.parried.connect(_on_player_parried)
	player.stunned.connect(_on_player_stunned)

# Stati hard, atomici del nemico
func _on_player_died():
	force_change_state("death")

func _on_player_stunned():
	force_change_state("stunned")

func _on_player_parried():
	force_change_state("parried")


func force_change_state(new_state_name: String):
	print("Forcing new state: ", new_state_name)

	var new_state = states.get(new_state_name.to_lower())
	if not new_state:
		return

	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter()


func change_to_knockback(state_name: String, knockback_direction: int = 0):
	var new_state : PlayerAbstractState = states.get(state_name.to_lower()) # Ottieni il riferimento al nodo stato

	if current_state:
		current_state.exit()

	# Controlla se il nuovo stato ha il metodo setup_knockback
	if state_name == "Knockback" and new_state.has_method("setup_knockback"):
		# Se sì, chiama il setup PRIMA di entrare
		new_state.setup_knockback(knockback_direction)

	current_state = new_state
	current_state.enter()

func get_state(state_name : String) -> PlayerAbstractState:
	return states.get(state_name.to_lower())
