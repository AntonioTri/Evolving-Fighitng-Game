extends AbstractEntity
class_name Player


@onready var inputs: PlayerInput = $Playerinput
@onready var player_movement: PlayerMovement = $PlayerMovement
@onready var player_visuals: PlayerVisuals = $PlayerVisuals
@onready var player_combat: ComboSystem = $PlayerCombat
@onready var player_abilities: Abilities = $PlayerAbilities
@onready var states: StateManager = $StateManager


func _ready() -> void:
	disable_collision_boxes()

# La process richiama l'update dello stato interno alla state machine
func _process(_delta):
	pass

# La physic process richiama l'update dello stato interno alla state machine
func _physics_process(delta):

	# Nel caso in cui il player non può muoversi, esce dalla funzione
	if not states.can_move():
		return

	# Aggiorna gli input del player
	inputs.update()
	
	# Aggiorna il movimento del player solo se non sta attaccando
	#TODO: valutare se aggiungere ua funzione per gli stati critici
	if not states.is_attacking():
		player_movement.physics_update(delta)
	
	# Aggiorna le visuali del player
	player_visuals.update(delta)
	# Aggiorna il sistema di combattimento del player
	player_combat.update()


# Gestion degli attacchi tramite il combo manager, viene solo segnalato l'avvenuto input
# Il sistema polimorfico ed astratto gestisce le combo da solo
func _input(event):

	if states.can_attack():
		pass
	
	if event.is_action_pressed("attack"):
		player_combat.start_combo()
	
	elif event.is_action_pressed("defence"):
		player_visuals.animation_player.play("parry")


func disable_collision_boxes():
	player_combat.get_child(0).monitorable = false
	player_combat.get_child(0).monitoring = false
	player_combat.get_child(1).monitorable = false
	player_combat.get_child(1).monitoring = false
