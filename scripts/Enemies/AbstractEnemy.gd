extends AbstractEntity
class_name AbstractEnemy

# Enumerazione che definisce il tipo di nemico
enum EnemyType {
	DUMMY,
	BUSH_GUARDIAN 
}

# Stato interno del nemico
enum EnemyState {
	IDLE,
	PATROLLING,
	MOVING_TOWARD_PLAYER,
	ATTACKING,
	PARRIED,
	STUNNED,
	ROTATING,
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
# Variabil interna per referenziarsi al player quando si è in combattimento
var player : Player = null
# Variabili booleane per conservare stati interni miniori
var can_move : bool = false
var can_attack : bool = false
var player_in_range : bool = false


# Reference ai raycast per il movimento
@onready var right_wall_ray_cast: RayCast2D = $RaycastingMovement/RightWallRayCast
@onready var left_wall_ray_cast: RayCast2D = $RaycastingMovement/LeftWallRayCast
@onready var right_floor_ray_cast: RayCast2D = $RaycastingMovement/RightFloorRayCast
@onready var left_floor_ray_cast: RayCast2D = $RaycastingMovement/LeftFloorRayCast
@onready var vision_ray_cast: RayCast2D = $SightOfView/RayCast2D
@onready var aggro_range: Area2D = $SightOfView
@onready var sprite: Sprite2D = $Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Viene conservato il valore necessario di parry per poterlo resettare dopo un critico
	parry_number = stun_parry_needed
	# Viene settata al direzione di patrolling iniziale in modo randomico
	direction = Direction.RIGHT if randi_range(0, 1) == 1 else Direction.LEFT
	# Impostazione dello stato su IDLE
	state = EnemyState.IDLE
	# Connessione dei segnali per gestire il campo visivo
	aggro_range.body_entered.connect(_on_body_entered)
	aggro_range.body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	react()


func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	move()
	update_vision_raycast()


# La funzione react gestisce le interazioni con il player e l'ambiente
# Calcolato normalmente, separato dai calcoli della fisica
func react():
	
	match state:
		EnemyState.ATTACKING:
			if can_attack:
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


# Questa funzione cambia la direzione del movimento i base alla direzione del player
func moving_toward_player():
	
	if player == null:
		return

	# Calcolo della direzione verso il player
	if player.global_position.x > global_position.x:
		direction = Direction.RIGHT
		sprite.flip_h = false
	else:
		direction = Direction.LEFT
		sprite.flip_h = true

	# Movimento verso il player
	velocity.x = SPEED * direction
	move_and_slide()


func attack():
	print("Enemy attacking!")


# L'unica implementata è quella di patrolling che generalmente funziona uguale per tutti i nemici
func patrolling():
	
	# Scelta della direzione in base al raycasting
	if direction == Direction.RIGHT:
		if can_walk_right():
			# Applicazione del vettore velocità
			velocity.x = SPEED
			# Funzione che muove il corpo della entity
			move_and_slide()
		else:
			print("Rotating to left")
			velocity.x = 0
			direction = Direction.LEFT
			can_move = false
			update_state(EnemyState.ROTATING) # Viene impostato lo stato su rotate
	
	elif direction == Direction.LEFT:
		if can_walk_left():
			# Applicazione del vettore velocità
			velocity.x = -SPEED
			# Funzione che muove il corpo della entity
			move_and_slide()
		else:
			print("Rotating to right")
			velocity.x = 0
			direction = Direction.RIGHT
			can_move = false
			update_state(EnemyState.ROTATING) # Viene impostato lo stato su rotate


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


# Funzione handler del segnale di quando il player entra nel campo visivo
func _on_body_entered(body : Node2D):
	
	print("Something in range of vision")
	
	if body.is_in_group("player"):
		print("Player Found")
		player = body as Player
		player_in_range = true


# Funzine handler di quando il player esce dal campo visivo
func _on_body_exited(body : Node2D):
	if body == player:
		print("Player uscito dal range di aggro")
		player = null
		player_in_range = false
		can_move = true
		update_state(EnemyState.PATROLLING)


func folow_player():
	# Ottenuta la reference facciamo puntare il raycast verso la posizione del player
	if player == null:
		return
	
	point_raycast_to_player()
	
	if is_player_visible():
		if state != EnemyState.MOVING_TOWARD_PLAYER:
			update_state(EnemyState.MOVING_TOWARD_PLAYER)
			print("Moving to player")
	else:
		if state == EnemyState.MOVING_TOWARD_PLAYER:
			update_state(EnemyState.PATROLLING)
			print("Back to patrolling")



func update_vision_raycast():
	if player_in_range:
		folow_player()


# Questa funzione aggiorna la posizione del raycast per 
# puntarlo verso la direzione del player
func point_raycast_to_player() -> void:
	if player == null:
		return
	
	# Direzione dal nemico al player
	var dir := player.global_position - global_position
	
	# Il RayCast2D vuole una posizione locale come target
	vision_ray_cast.target_position = dir
	vision_ray_cast.force_raycast_update()


# Invece questa funzione ci aiuta a capire se il vision raycast incrocia il player
func is_player_visible() -> bool:
	if player == null:
		return false
	
	vision_ray_cast.force_raycast_update()
	
	if not vision_ray_cast.is_colliding():
		return false
	
	var hit := vision_ray_cast.get_collider()
	return hit == player


# Questa funzione ritorna true se il nemico può camminare a destra, altrimenti ritorna false
func can_walk_right() -> bool:
	return right_floor_ray_cast.is_colliding() and not right_wall_ray_cast.is_colliding()


# Questa funzione ritorna true se il nemico può camminare a destra, altrimenti ritorna false
func can_walk_left() -> bool:
	return left_floor_ray_cast.is_colliding() and not left_wall_ray_cast.is_colliding()


# Funzione che gestisce la logica di danno
func take_damage(value : int):
	
	# Viene skippato tutto se l'entità sta morendo
	if invulnerability:
		return
	
	if health - value <= 0:
		# L'entità viene resa invulnerabile per darle il tempo di morire
		# Anche per evitare dei possibili bug
		make_invulnerable()
		print("Enemy "+ str(enemy_type) + " dieing.")
		update_state(EnemyState.DYING)
		# Viene anche impostata la flag per l'attacco a false per impedire bug
		can_attack = false
		can_move = false
	
	else:
		health -= value
		print("Enemy "+ str(enemy_type) + " got damaged with " + str(value) + " damage. Current health: " + str(health))


# Banale funzione per applicare la gravità
func apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
		move_and_slide()
	else:
		can_move = true


# La funzione che gestisce la morte della entità
func die():
	
	#$AnimationPlayer.play("death")
	#await $AnimationPlayer.animation_finished
	print("Rimozione dalla scena")
	queue_free()


# Funzione che cambia lo stato interno
func update_state(new_state : EnemyState):
	state = new_state


func get_knockbacked():
	print("Enemy got knockbacked.")


func reset_needed_parry_number():
	stun_parry_needed = parry_number


# Funzione da implementare nelle classi figlie per permettere di fare le animazioni
func do_animation():
	pass
