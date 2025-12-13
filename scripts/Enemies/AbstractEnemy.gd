extends AbstractEntity
class_name AbstractEnemy

# Enumerazione che definisce il tipo di nemico
enum EnemyType {
	DUMMY,
	BUSH_GUARDIAN 
}

# Stato interno del nemico
enum EnemyState {
	SPWANING,
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
# Il range di idleing verso il player
@export var idleing_range : float = 50.0
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
var attack_locked := false
var player_in_range : bool = false
# Variabile che consreva lo stato precedente al rotating
var state_pre_rotating : EnemyState


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
	state = EnemyState.SPWANING
	# Connessione dei segnali per gestire il campo visivo
	aggro_range.body_entered.connect(_on_body_entered)
	aggro_range.body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	react(delta)


func _physics_process(delta: float) -> void:
	
	apply_gravity(delta)

	if not can_move: # La funzione ritorna e blocca il movimento se non è permesso 
		return
	
	move()
	update_vision_raycast()


# La funzione react gestisce le interazioni con il player e l'ambiente
# Calcolato normalmente, separato dai calcoli della fisica
func react(delta: float):
	
	match state:
		EnemyState.ATTACKING:
			if can_attack:
				attack(delta)
		EnemyState.DYING:
			die()


# La logica del patrolling, che definisce il movimento, l'allert
# Calcolato nella fisica degli oggetti
func move():

	match state:
		EnemyState.SPWANING:
			spawning()
		EnemyState.IDLE:
			idleing()
		EnemyState.PATROLLING:
			patrolling()
		EnemyState.MOVING_TOWARD_PLAYER:
			moving_toward_player()
		EnemyState.ROTATING:
			change_direction()


func spawning():
	# Utilizzo generale che attende che il nemico sia sul terreno
	if is_on_floor():
		allow_movement()
		update_state(EnemyState.PATROLLING)

# Questi metodi vengono lasciati vuoti per permettere ad ogni tipologia di nemico
# di implementarle a piacimento
func idleing():
	pass


# L'unica implementata è quella di patrolling che generalmente funziona uguale per tutti i nemici
func patrolling():

	do_walk_animation()

	# Scelta della direzione in base al raycasting
	if direction == Direction.RIGHT:
		if can_walk_right():
			# Applicazione del vettore velocità
			velocity.x = SPEED
			# Funzione che muove il corpo della entity
			move_and_slide()
		else:
			print("Rotating to left")
			rotate_for_patrolling(Direction.LEFT)
	
	elif direction == Direction.LEFT:
		if can_walk_left():
			# Applicazione del vettore velocità
			velocity.x = -SPEED
			# Funzione che muove il corpo della entity
			move_and_slide()
		else:
			print("Rotating to right")
			rotate_for_patrolling(Direction.RIGHT)


# Funzione ausiliaria per la rotazione durante il patrolling
func rotate_for_patrolling(direction_to_rotate: int):
	velocity.x = 0
	direction = direction_to_rotate
	state_pre_rotating = EnemyState.PATROLLING
	block_movement()
	update_state(EnemyState.ROTATING) # Viene impostato lo stato su rotate


# Funzione handler del segnale di quando il player entra nel campo visivo
func _on_body_entered(body : Node2D):
	
	if body.is_in_group("player"):
		player = body as Player
		player_in_range = true


# Funzine handler di quando il player esce dal campo visivo
func _on_body_exited(body : Node2D):
	if body == player:
		player = null
		player_in_range = false
		allow_movement()
		update_state(EnemyState.PATROLLING)


# Questa funzione aggiorna il raycast di visione per seguire il player
# quando questo è nel range di visione
func update_vision_raycast():
	if player_in_range:
		follow_player()


func follow_player():
	# Ottenuta la reference facciamo puntare il raycast verso la posizione del player
	if player == null or attack_locked:
		return

	# NON interferire con stati critici
	if in_critical_state():
		return
	
	point_raycast_to_player()
	
	if is_player_visible():
		if state != EnemyState.MOVING_TOWARD_PLAYER:
			update_state(EnemyState.MOVING_TOWARD_PLAYER)
	else:
		if state == EnemyState.MOVING_TOWARD_PLAYER:
			update_state(EnemyState.PATROLLING)


func in_critical_state() -> bool:
	return state == EnemyState.ATTACKING \
	or state == EnemyState.STUNNED \
	or state == EnemyState.PARRIED \
	or state == EnemyState.ROTATING \
	or state == EnemyState.DYING


# Questa funzione cambia la direzione del movimento i base alla direzione del player
func moving_toward_player():
	
	if player == null:
		return

	# Controllo se il player è entro il range di idleing e non attaccabile	
	if is_player_near() and not is_player_attackable():
		idleing()
	
	elif is_player_attackable():
		print("Player is attackable")
		if not is_facing_player():
			print("Not facing player")
			request_face_player_for_attack()
			return
		
		attack_behavior()
	
	else:

		do_walk_animation()

		if in_critical_state():
			return

		# Calcolo della direzione verso il player
		if player.global_position.x > global_position.x and state:
			print("Moving toward player on the RIGHT")
			if direction == Direction.LEFT:
				print("Changing to RIGHT for chasing")
				direction = Direction.RIGHT
				rotating_for_chaising()
				return
				
			direction = Direction.RIGHT
			sprite.flip_h = false
		
		else:
			print("Moving toward player on the LEFT")
			if direction == Direction.RIGHT:
				print("Changing to LEFT for chasing")
				direction = Direction.LEFT
				rotating_for_chaising()
				return
			
			direction = Direction.LEFT
			sprite.flip_h = true

		# Movimento verso il player
		velocity.x = SPEED * direction
		move_and_slide()


# Funzione ausiliaria per la funzione di sopra
func rotating_for_chaising():
	state_pre_rotating = EnemyState.MOVING_TOWARD_PLAYER
	block_movement()
	block_attack()
	update_state(EnemyState.ROTATING)


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
	
	if not vision_ray_cast.is_colliding():
		return false
	
	var hit := vision_ray_cast.get_collider()
	return hit == player


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


# Funzione che gestisce la logica di danno
func take_damage(value : int):
	
	# Viene skippato tutto se l'entità sta morendo
	if invulnerability or not is_player_visible():
		return
	
	# Hit flashper feedback
	flash_white(0.2)
	
	if health - value <= 0:
		# L'entità viene resa invulnerabile per darle il tempo di morire
		# Anche per evitare dei possibili bug
		make_invulnerable()
		# Viene anche impostata la flag per l'attacco a false per impedire bug
		block_attack()
		block_movement()
		print("Enemy "+ str(enemy_type) + " dieing.")
		update_state(EnemyState.DYING)
	
	else:
		health -= value

# Banale funzione per applicare la gravità
func apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
		move_and_slide()
	elif state != EnemyState.DYING:
		allow_movement()


# La funzione che gestisce la morte della entità
func die():
	
	#$AnimationPlayer.play("death")
	#await $AnimationPlayer.animation_finished
	print("Rimozione dalla scena")
	queue_free()


# Questa funzione ritorna true se il nemico può camminare a destra, altrimenti ritorna false
func can_walk_right() -> bool:
	return right_floor_ray_cast.is_colliding() and not right_wall_ray_cast.is_colliding()


# Questa funzione ritorna true se il nemico può camminare a destra, altrimenti ritorna false
func can_walk_left() -> bool:
	return left_floor_ray_cast.is_colliding() and not left_wall_ray_cast.is_colliding()


# Funzione che cambia lo stato interno
func update_state(new_state: EnemyState):
	if state == new_state:
		return
	state = new_state


func get_knockbacked():
	print("Enemy got knockbacked.")

# Hit flash per qunado un nemico viene colpito
func flash_white(duration := 0.1):
	var mat := sprite.material as ShaderMaterial
	if mat == null:
		return

	mat.set_shader_parameter("flash_strength", 1.0)

	var tween := get_tree().create_tween()
	tween.tween_property(
		mat,
		"shader_parameter/flash_strength",
		0.0,
		duration
	)

# Questa funzione ritorna true se il player è entro il range designato
# Dovrebbe essere eseguita esclusivamente se il cooldown di attacco non è ancora finito
func is_player_near():
	pass


func is_facing_player() -> bool:
	if player == null:
		return false
	
	if player.global_position.x > global_position.x and direction == Direction.RIGHT:
		print(direction)
		print(sprite)
		return true
	elif player.global_position.x < global_position.x and direction == Direction.LEFT:
		print(direction)
		return true

	return false


func request_face_player_for_attack():
	var desired_dir := Direction.RIGHT if player.global_position.x > global_position.x else Direction.LEFT
	
	if desired_dir != direction:
		direction = desired_dir
		state_pre_rotating = EnemyState.MOVING_TOWARD_PLAYER
		block_movement()
		block_attack()
		update_state(EnemyState.ROTATING)
		print("Requesting to face player.")


func reset_needed_parry_number():
	stun_parry_needed = parry_number

func attack(_delta: float):
	print("Enemy attacking!")

# Funzione da implementare nelle classi figlie per permettere di fare le animazioni
func is_player_attackable():
	pass

func do_walk_animation():
	pass

func attack_behavior():
	pass

func change_direction():
	pass

func allow_movement():
	can_move = true

func block_movement():
	can_move = false

func allow_attack():
	can_attack = true

func block_attack():
	can_attack = false
