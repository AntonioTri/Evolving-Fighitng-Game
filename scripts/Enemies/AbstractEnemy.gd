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
	CHAISING,
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
# Variabili per il chaising behavior
@export var CHAISING_SPEED : float = SPEED

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
# Variabile per checkare lo stato di flipping e ruotare lo sprite e pe conservare lo stato pre rotation
var should_flip_h : bool = false
var status_pre_rotate : EnemyState


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
	sprite.flip_h = true if direction == Direction.LEFT else false
	# Impostazione dello stato su IDLE
	state = EnemyState.SPWANING
	# Connessione dei segnali per gestire il campo visivo
	aggro_range.body_entered.connect(_on_body_entered)
	aggro_range.body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	react()


func _physics_process(delta: float) -> void:
	
	check_if_should_flip_h()

	apply_gravity(delta)
	
	move()

# Questa funzione atomica flippa lo sprite qando la flag è alzata
func check_if_should_flip_h():
	if should_flip_h:
		should_flip_h = false
		if direction == Direction.RIGHT:
			sprite.flip_h = false
		elif direction == Direction.LEFT:
			sprite.flip_h = true


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

	match state:
		EnemyState.SPWANING:
			spawning()
		EnemyState.IDLE:
			idleing()
		EnemyState.ROTATING:
			do_rotation()
		EnemyState.PATROLLING:
			if can_move: # Solo se il movimento è permesso 
				patrolling()
		EnemyState.CHAISING:
			if can_move: # Solo se il movimento è permesso
				chaising()


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

	# Se il player è in range di visione viene updatato lo stato e la funzine ritorna
	if player_in_range:
		# Viene aggiornata la posizione del raycasting di visione
		point_raycast_to_player()
		# Se il player non è visibile si cambia stato e si torna al patrolling
		if is_player_visible():
			print("Player visible, changing status to chaising")
			update_state(EnemyState.CHAISING)
			return


	# Scelta della direzione in base al raycasting
	if direction == Direction.RIGHT:
		if can_walk_right():
			# Applicazione del vettore velocità
			velocity.x = SPEED
			# Funzione che muove il corpo della entity
			move_and_slide()
		else:
			print("Rotating to left")
			direction = Direction.LEFT
			patrolling_rotation()
	
	elif direction == Direction.LEFT:
		if can_walk_left():
			# Applicazione del vettore velocità
			velocity.x = -SPEED
			# Funzione che muove il corpo della entity
			move_and_slide()
		else:
			print("Rotating to right")
			direction = Direction.RIGHT
			patrolling_rotation()


# funzione ausiliaria per la precedente
func patrolling_rotation():
	velocity.x = 0
	block_movement()
	rotate_enemy() # Il nemico viene ruotato

			

# Questa funzione cambia la direzione del movimento i base alla direzione del player
func chaising():
	
	if player == null or is_in_critical_state():
		return

	# Se invece è visibile si controlla che il nemicolo stia guardando
	if not is_enemy_facing_player():
		# Viene impostato lo stato su rotate e conservato lo stato di chaising
		print("Enemy not facing player, rotating")
		direction = Direction.LEFT if direction == Direction.RIGHT else Direction.RIGHT
		rotate_enemy()
		return

	# Viene aggiornata la posizione del raycasting di visione
	point_raycast_to_player()

		# Se il player non è visibile si cambia stato e si torna al patrolling
	if not is_player_visible():
		print("Player not visible, back to patrolling")
		update_state(EnemyState.PATROLLING)
		return

	# Controllo se il player è entro il range di idleing e non attaccabile	
	if is_player_near() and not is_player_attackable():
		idleing()
	
	elif is_player_attackable():
		attack_behavior()
	
	else :

		do_walk_animation()

		# Movimento verso il player
		velocity.x = CHAISING_SPEED * direction
		move_and_slide()


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


# Funzione che controlla se il nemico è in stato critico
func is_in_critical_state():
	return 	   state == EnemyState.ATTACKING \
			or state == EnemyState.STUNNED \
			or state == EnemyState.PARRIED \
			or state == EnemyState.ROTATING \
			or state == EnemyState.DYING


# Questa funzione ci aiuta a capre se il nemico sta guardando nella direzine giusta
func is_enemy_facing_player():
	
	if player == null:
		return
	
	if global_position.x < player.global_position.x  and direction == Direction.RIGHT:
		return true
	elif global_position.x > player.global_position.x and direction == Direction.LEFT:
		return true
	
	# Altrimenti ritorna false in ogni caso
	return false


# Funzione handler del segnale di quando il player entra nel campo visivo
func _on_body_entered(body : Node2D):
	
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
		allow_movement()
		update_state(EnemyState.PATROLLING)


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
		print("Enemy "+ str(enemy_type) + " got damaged with " + str(value) + " damage. Current health: " + str(health))


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


# Vengono anche bloccati i movimenti e gli attacchi per render o stato atomico
func rotate_enemy():
	status_pre_rotate = state
	block_movement()
	block_attack()
	update_state(EnemyState.ROTATING)


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
	if player == null:
		return false
	
	var distance := global_position.distance_to(player.global_position)
	return distance <= idleing_range


func reset_needed_parry_number():
	stun_parry_needed = parry_number

func attack():
	pass

# Funzione da implementare nelle classi figlie per permettere di fare le animazioni
func is_player_attackable():
	pass

func do_walk_animation():
	pass

func do_rotation():
	pass

func attack_behavior():
	pass

func allow_movement():
	can_move = true

func block_movement():
	can_move = false

func allow_attack():
	can_attack = true

func block_attack():
	can_attack = false
