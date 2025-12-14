extends AbstractEntity

class_name Player_

# Variabili per settare la potenza di alcune azioni
@export var RUNNING_MULTIPLAYER = 1.5
@export	var JUMP_VELOCITY = -400.0

# Reference ai nodi utili
@onready var sprite: Sprite2D = $Sprite2D
@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var running_timer: Timer = $Timer
@onready var combat_root: Node2D = $CombatRoot
@onready var attack_manager: Node2D = $CombatRoot/AttackManager
@onready var parry_box: CollisionBox = $CombatRoot/ParryBox
@onready var attack_box: CollisionBox = $CombatRoot/AttackBox

# Variabili booleane per gestire gli stati interni
var direction : int = Direction.STILL
var stunned : bool
var can_move : bool = true
var can_attack : bool = true
var walking : bool = false
var running : bool = false
# Variabili per la corsa dopo un secondo
var run_hold_time := 0.0
var HOLD_THRESHOLD := 1.0



func _ready() -> void:
	disable_collision_boxes()


func _process(delta: float) -> void:

	# Viene impedito ogni tipo di interazione se il player è stunanto
	if stunned:
		return
	
	handle_running(delta)


func _physics_process(delta: float) -> void:

	# Viene impedito ogni tipo di interazione fisica se il player è stunanto
	if stunned:
		return
	# Se non è attualmente concesso il movimento la funzione ritorna ed ignora tutto
	if not can_move:
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = int(Input.get_axis("move_left", "move_right"))
	
	if direction == Direction.STILL:  # Caso in cui sono fermo
		idle()
	else	:              # Caso del movimento
		move()
	
	move_and_slide()


# La funzione che gestisce la corsa
func handle_running(delta : float):
	
	if Input.is_action_pressed("run"):
		run_hold_time += delta
	else:
		run_hold_time = 0.0
	
	# Viene attivata la corsa solo se la soglia è superata e c'è input direzionale
	if run_hold_time >= HOLD_THRESHOLD and direction != Direction.STILL:
		running = true
		walking = false
	else:
		if direction != Direction.STILL:
			running = false
			walking = true
		else:
			running = false
			walking = false


func idle():
	
	walking = false
	running = false
	animator.play("idle")
	velocity.x = move_toward(velocity.x, 0, SPEED)


func move():
	# Velocità
	var speed_multiplier = RUNNING_MULTIPLAYER if running else 1.0
	velocity.x = direction * SPEED * speed_multiplier
	
	# Spostamento caso camminata e corsa
	if direction == Direction.STILL:
		animator.play("idle")
	elif running:
		animator.play("run")
	else:
		animator.play("walk")
	
	# Flip delle attackbox e parry box
	sprite.flip_h = direction < 0
	combat_root.scale.x = -1 if direction < 0 else 1


# Quando finisce il timer associato se la direzione è ancora diversa da 0 allora attiviamo la corsa
func start_running():
	if direction != 0 and walking:
		walking	= false
		running = true


# Gestion degli attacchi tramite il combo manager, viene solo segnalato l'avvenuto input
# Il sistema polimorfico ed astratto gestisce le combo da solo
func _input(event):

	if can_attack:
		pass
	
	if event.is_action_pressed("attack"):
		attack_manager.start_combo()
	
	elif event.is_action_pressed("defence"):
		animator.play("parry")


func disable_collision_boxes():
	attack_box.monitorable = false
	attack_box.monitoring = false
	parry_box.monitorable = false
	parry_box.monitoring = false

func get_parried():
	print("Player parried")

# Funzione che attiva la possibilità di muoversi
func allow_movement():
	can_move = true

# Funzione che blocca la possibilità di muoversi
func block_movement():
	can_move = false

func get_stunned():
	stunned = true

func remove_stun():
	stunned = false

