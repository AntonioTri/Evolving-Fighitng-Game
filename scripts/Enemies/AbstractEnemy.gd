extends AbstractEntity
class_name AbstractEnemy

# Enumerazione che definisce il tipo di nemico
enum EnemyType {
	DUMMY,
	SOMEHTING 
}

# Stato interno del nemico
enum EnemyState {
	IDLE,
	PATROLLING,
	MOVING_TOWARD_PLAYER,
	ATTACKING,
	DYING
}

# Il tipo del nemico scelto da una enumerazione
@export var enemy_type : EnemyType
# Il valore dello scudo del nemico
@export var shield_amount : int = 0
# Il numero di parry iniziali, serve a resettare il numero di quelli necessari dopo un critico
var parry_number : int
# Il valore che identifica la direzione
var direction : int
# La variabile che conserva lo stato
var state : EnemyState
# Variabili booleane per conservare stati interni miniori
var can_move : bool = false
var can_attack : bool = false


# Reference ai raycast per il movimento
@onready var right_wall_ray_cast: RayCast2D = $RaycastingMovement/RightWallRayCast
@onready var left_wall_ray_cast: RayCast2D = $RaycastingMovement/LeftWallRayCast
@onready var right_floor_ray_cast: RayCast2D = $RaycastingMovement/RightFloorRayCast
@onready var left_floor_ray_cast: RayCast2D = $RaycastingMovement/LeftFloorRayCast


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Viene conservato il valore necessario di parry per poterlo resettare dopo un critico
	parry_number = stun_parry_needed
	# Viene settata al direzione di patrolling iniziale in modo randomico
	direction = Direction.RIGHT if randi_range(0, 1) == 1 else Direction.LEFT
	# Impostazione dello stato su IDLE
	state = EnemyState.IDLE


func _process(_delta: float) -> void:
	react()

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	move()



# La funzione react gestisce le interazioni con il player e l'ambiente
# Calcolato normalmente, separato dai calcoli della fisica
func react():
	if not can_attack: # La funzione ritorna e blocca il react se non è permesso 
		return
	
	match state:
		EnemyState.ATTACKING:
			attack()
		EnemyState.DYING:
			die()



# La logica del patrolling, che definisce il movimento, l'allert
# Calcolato nella fisica degli oggetti
func move():
	if not can_move: # La funzione ritorna e blocca il movimento se non è permesso 
		return
	
	match state:
		EnemyState.IDLE:
			idleing()
		EnemyState.PATROLLING:
			patrolling()
		EnemyState.MOVING_TOWARD_PLAYER:
			moving_toward_player()



# Questi metodi vengono lasciati vuoti per permettere ad ogni tipologia di nemico
# di implementarle a piacimento
func idleing():
	# Utilizzo generale che attende che il nemico sia sul terreno
	if is_on_floor():
		can_move = true
		update_state(EnemyState.PATROLLING)

func moving_toward_player():
	print("Enemy moving to player")

func attack():
	print("Enemy attacking!")

# L'unica implementata è quella di patrolling che generalmente funziona uguale per tutti i nemici
func patrolling():
	
	# Scelta della direzione in base al raycasting
	if direction == Direction.RIGHT:
		if can_walk_right():
			velocity.x = SPEED
		else:
			direction = Direction.LEFT
	elif direction == Direction.LEFT:
		if can_walk_left():
			velocity.x = -SPEED
		else:
			direction = Direction.RIGHT
	
	# Applicazione del vettore velocità
	velocity.x = SPEED * direction
	# Funzione che muove il corpo della entity
	move_and_slide()


# Quando questa funzione viene chiamata viene sottratto un parry necessario allo stunn
# se siamo a 0 il nemico viene stunnato
func get_parried_with_damage(value : int):
	# Per prima cosa controlliamo se col danno preso il nemico deve morire
	# in tal caso la funzione take_damage finirà l'handler da sola
	take_damage(value)
	
	# Banale logica di parry
	if stun_parry_needed > 0:
		stun_parry_needed -= 1
	else:
		get_stunned()
	print("Enemy got parried.")


func get_stunned():
	print("Enemy got stunned.")
	# !!!!! PLACEHOLDER !!!!!
	reset_needed_parry_number() # Questa funzione sta qua per testing

# Funzione che cambia lo stato interno
func update_state(new_state : EnemyState):
	state = new_state
	print("Status changed to ", state)

# Banale funzione per applicare la gravità
func apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
		move_and_slide()
	else:
		can_move = true

# Questa funzione ritorna true se il nemico può camminare a destra, altrimenti ritorna false
func can_walk_right() -> bool:
	if right_floor_ray_cast.is_colliding() and not right_wall_ray_cast.is_colliding():
		return true
	return false

# Questa funzione ritorna true se il nemico può camminare a destra, altrimenti ritorna false
func can_walk_left() -> bool:
	if left_floor_ray_cast.is_colliding() and not left_wall_ray_cast.is_colliding():
		return true
	return false

func get_knockbacked():
	print("Enemy got knockbacked.")

func reset_needed_parry_number():
	stun_parry_needed = parry_number
