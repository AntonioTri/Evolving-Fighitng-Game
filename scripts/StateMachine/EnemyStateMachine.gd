class_name NodeFineteStateMahcine
extends Node

@export var owner_entity : AbstractEnemy
@export var sprite : Sprite2D
@export var animator : AnimationPlayer
@export var starting_state : EnemyAbstractState


var states : Dictionary = {}
var current_state : EnemyAbstractState


func _ready() -> void:
	
	for child in get_children():
		
		# Per ogni stato interno alla state machine vengon assegnate le referenze a:
		# 1. funzione di transizione
		# 2. Entità proprietaria
		# 3. Sprite2D proprietario
		# 4. AniamtorPlayer proprietario
		
		if child is EnemyAbstractState:
			states[child.name.to_lower()] = child
			child.transition.connect(change_state)
			child.owner_body = owner_entity
			child.sprite = sprite
			child.animator = animator

	# Se presente viene impostato uno stato di partenza
	if starting_state:
		starting_state.enter()
		current_state = starting_state

# La funzione process chiama la process dello stato corrente
func _process(delta: float) -> void:
	if current_state:
		current_state.on_process(delta)

# La funzione physics process chiama la relativa funzine delo stato corrente
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.on_physics_process(delta)

# Questa funzine collegata al segnale interno degli stati, cambia lo stato corrente con quello in input
func change_state(old_state : EnemyAbstractState, new_state_name: String) -> void:
	
	# Se il vecchio stato e quello attuale non matchano viene catturato il bug
	if current_state != old_state:
		print("Bug found, old state and current state are not matching")
		return
	
	# Caso in cui lo stato sia lo stesso
	if new_state_name == current_state.name.to_lower():
		print("Enemy alredy in the " + current_state.name.to_lower() + " state.")
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
	print("Changing State machine: changing state to ", new_state_name)
	current_state = new_state
