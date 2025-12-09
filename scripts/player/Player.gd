extends AbstractEntity

class_name Player

@export var RUNNING_MULTIPLAYER = 1.5
@export	var JUMP_VELOCITY = -400.0


@onready var sprite: Sprite2D = $Sprite2D
@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var running_timer: Timer = $Timer
@onready var combat_root: Node2D = $CombatRoot
@onready var attack_manager: Node2D = $CombatRoot/AttackManager


var direction : int = 0
var can_move : bool = true
var walking : bool = false
var running : bool = false


func _physics_process(delta: float) -> void:
	
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

	if direction == 0:  # Caso in cui sono fermo
		idle()
	else	:              # Caso del movimento
		move()

	move_and_slide()



func idle():

	walking = false
	running = false
	animator.play("idle")
	velocity.x = move_toward(velocity.x, 0, SPEED)


func move():

	# Se il pg non sta camminando o correndo allora settiamo la flag per camminare 
	# ed iniziamo il timer di running
	if not walking and not running:
		walking = true
		running_timer.start()


	# Spostamento caso camminata e corsa
	if  walking and not running:
		velocity.x = direction * SPEED
		animator.play("walk") # Animazione
	elif not walking and running:
		velocity.x = direction * SPEED * RUNNING_MULTIPLAYER
		animator.play("run") # Animazione


	sprite.flip_h = true if direction < 0 else false		# Flip dello sprite
	combat_root.scale.x = -1 if direction < 0 else 1		# Flip delle attackbox e parry box

# Quando finisce il timer associato se la direzione è ancora diversa da 0 allora attiviamo la corsa
func _on_timer_timeout() -> void:
	running_timer.stop()
	if direction != 0 and walking:
		walking	= false
		running = true


# Gestion degli attacchi tramite il combo manager, viene solo segnalato l'avvenuto input
# Il sistema polimorfico ed astratto gestisce le combo da solo
func _input(event):

	if event.is_action_pressed("attack"):
		attack_manager.start_combo()

	elif event.is_action_pressed("defence"):
		animator.play("parry")


func get_parried():
	print("Player parried")


# Funzione che attiva la possibilità di muoversi
func allow_movement():
	can_move = true

# Funzione che blocca la possibilità di muoversi
func block_movement():
	can_move = false


func set_attacking(flag : bool):
	is_attacking = flag
