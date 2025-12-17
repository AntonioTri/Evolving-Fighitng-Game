extends AbstractEntity
class_name Player

# Variabili per definire delle caratteristiche del player
@export_group("Movement Settings")
@export var MOVEMENT_SPEED = 200.0
@export var RUNNING_MULTIPLIER = 1.5

@export_group("Jump Settings Settings")
@export var jump_height : float = 60.0
@export var jump_time_to_peak : float = 0.34
@export var jump_time_to_descend : float = 0.28
@export var min_jump_duration: float = 0.15
@export var coyote_time_duration: float = 0.15 # Il tempo concesso per il Coyote Jump
var _last_time_on_floor: float = -1.0

# Nel Player.gd
@export_group("Dash Settings")
@export var dash_speed: float = 600.0
@export var dash_distance: float = 150.0
@export var dash_cooldown: float = 1.5
@export var jump_dash_falling_speed : float = 300
var can_dash: bool = true
var dash_cooldown_timer : float = 0.0

# Variabili per gestire il knockback da prendere
var knockback_force: float = 300.0 # Forza base del respingimento
var knockback_angle_degree: float = 37.0 # Angolo di respingimento in gradi

# Variabili di riferimento per le sottocomponenti
@onready var visuals: PlayerVisuals = $PlayerVisuals
@onready var inputs: PlayerInputComponent = $PlayerInputs
@onready var progressions: PlayerProgression = $ProgressionManage
@onready var collisoin_boxes: Node2D = $CollisoinBoxes
@onready var combat_system: ComboSystem = $CombatSystem
@onready var state_machine: PlayerFineteStateMahcine = $StateMachine

# Segnali per eventi di stato hard o di assoluta priorità
signal died
signal parried
signal stunned

# Variabile che conserva l'ultima direzione orizzontale del player
var last_direction := Direction.STILL

func _ready() -> void:
	
	disable_collision_boxes()

	# --- INIZIALIZZAZIONE DEGLI STATI ---
	# 1. Ottengo lo stato Jump dalla FSM
	var jump_state = state_machine.get_state("Jump")
	var knockback_state = state_machine.get_state("Knockback")

	# 2. Inizializzo le costanti fisiche solo dopo che il Player è pronto
	if jump_state: jump_state.initialize_physics_constants()
	if knockback_state : knockback_state.initialize_physics_constants()


# La process aggiorna delle variabili di stato importanti
func _process(_delta):
	if inputs.direction == 1 or inputs.direction == -1:
		last_direction = inputs.direction
	
	# Aggiornamento del cooldown del dash
	if not can_dash:
		dash_cooldown_timer += _delta
		print("Charging dash: ", dash_cooldown_timer)
		if dash_cooldown_timer >= dash_cooldown:
			can_dash = true
			dash_cooldown_timer = 0.0
			print("Dash ready")

# La physic process aggiorna delle variabili di stato importanti
func _physics_process(_delta):
	# Aggiorna la variabile time_on_floor
	if is_on_floor():
		_last_time_on_floor = Time.get_ticks_msec() / 1000.0

# Metodo che fa prendere danno al player
func take_damage(value : int):
	
	if invulnerability : return 	# Resa di invulnerabilità
	health -= value 				# Scalo sulla vita
	if health < 0 : health = 0 		# Bug handling per le interfaccie
	
	if health == 0:
		print("Player dieing")
		make_invulnerable()
		died.emit()
		return
	else:
		print("Player toke " + str(value) +" damage. Current health: " + str(health))
		flash_white(0.15)

# Funzione per gli stati per interrogare il Coyote Time
func is_coyote_time_active() -> bool:
	if is_on_floor():
		return false

	var time_now = Time.get_ticks_msec() / 1000.0
	var coyote_avayable = (time_now - _last_time_on_floor) < coyote_time_duration
	print("Coyote avayable" if coyote_avayable else "Coyote spoiled")
	return coyote_avayable

func disable_collision_boxes():
	collisoin_boxes.get_child(0).monitorable = false
	collisoin_boxes.get_child(0).monitoring = false
	collisoin_boxes.get_child(1).monitorable = false
	collisoin_boxes.get_child(1).monitoring = false

# Funzione per venire parriati
func get_parried():
	print("Player parried")
	current_parry_needed_for_stunn -= 1
	
	if current_parry_needed_for_stunn <= 0:
		print("Emitting stunned")
		current_parry_needed_for_stunn = stun_parry_needed
		stunned.emit()

# La funzine per applicare al player un knockback con forza direzione ed angolo
func gain_knockback(force : float, angle : int, direction : int):
	set_knockback_force_and_angle(force, angle)
	state_machine.change_to_knockback("Knockback", direction)

func set_knockback_force_and_angle(force : float, angle : int):
	self.knockback_force = force
	self.knockback_angle_degree = angle
