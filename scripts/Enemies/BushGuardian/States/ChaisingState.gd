extends EnemyAbstractState

@export var CHAISING_SPEED : float

var bush_guardian : BushGuardian

# Reference al raycast per il movimento
@onready var right_wall_ray_cast: RayCast2D = $"../../RaycastingMovement/RightWallRayCast"
@onready var left_wall_ray_cast: RayCast2D = $"../../RaycastingMovement/LeftWallRayCast"
@onready var right_floor_ray_cast: RayCast2D = $"../../RaycastingMovement/RightFloorRayCast"
@onready var left_floor_ray_cast: RayCast2D = $"../../RaycastingMovement/LeftFloorRayCast"
# Reference ai range per cambiare lo stato in attacco quando possibile
@onready var melee_range: Area2D = $"../../AttackRanges/MeleeRange"
@onready var pull_range: Area2D = $"../../AttackRanges/PullRange"
# Reference al vision raycast
@onready var vision_ray_cast: RayCast2D = $"../../SightOfView/RayCast2D"

# Flag per andare nello stato di attacco corretto
var do_melee : bool = false
var do_pull : bool = false

func on_process(_delta: float) -> void:
	pass

func on_physics_process(_delta: float) -> void:
	# Bug handling
	if player == null: return
	
	# Se il player non è in range di visione lo stato torna a patrolling
	if not owner_enemy.can_see_player: 
		transition.emit(self, "patrolling")
		return
	
	# Se il nemico non sta guardano il player finisce in stato di rotate
	if ( owner_enemy.global_position.x < player.global_position.x and owner_enemy.direction == -1 ) \
	or ( owner_enemy.global_position.x > player.global_position.x and owner_enemy.direction == 1 ):
		transition.emit(self, "rotating")
		return
	
	chaise(_delta)
	# Altrimenti viene applicato il movimento

func enter() -> void:
	player = get_player()
	animator.play("walk")
	# Casting referenziato al nemico
	var body = owner_enemy.get_type_reference()
	if body is BushGuardian:
		bush_guardian = body as BushGuardian

func exit() -> void:
	pass

# La funzione chaise esegue uno spostamento nel nemico nella attuale direzione
func chaise(_delta : float):

	# Questa prima parte viene seguita per dare priorità allo stato di attacco quando disponibile
	if can_enemy_attack():
		if attack_behaviour():
			return


	# Se siamo in range di attacco melee ed abbiamo saltato il controllo precedente
	# vuol dire che il timer non era ancora pronto. Dunque il nemico si ferma a melee
	# range e gioca la animazione di idle, la funzione quindi ritorna
	if not bush_guardian.melee_ready and player_in_range(melee_range):
		if animator.current_animation != "idle":
			animator.play("idle")
		return

	
	# Piccolo edge case per iniziare la animazione di walk se non sta venendo eseguita
	if animator.current_animation != "walk": animator.play("walk")

	# Se abbiamo saltato le due precedenti condizioni effetuiamo un chaise normale
	# in quanto il player è lontano, visibile e raggiungibile
	if owner_enemy.direction == Direction.RIGHT and can_walk_right():
			# Applicazione del vettore velocità
			owner_enemy.velocity.x = CHAISING_SPEED
			# Funzione che muove il corpo della entity
			owner_enemy.move_and_slide()
			return
	elif not can_walk_right():
		animator.play("idle")
		return

	if owner_enemy.direction == Direction.LEFT and can_walk_left():
			# Applicazione del vettore velocità
			owner_enemy.velocity.x = -CHAISING_SPEED
			# Funzione che muove il corpo della entity
			owner_enemy.move_and_slide()
			return
	elif not can_walk_right():
		animator.play("idle")
		return


# Questa funzione ritorna true se il nemico può camminare a destra, altrimenti ritorna false
func can_walk_right() -> bool:
	return right_floor_ray_cast.is_colliding() and not right_wall_ray_cast.is_colliding()

# Questa funzione ritorna true se il nemico può camminare a destra, altrimenti ritorna false
func can_walk_left() -> bool:
	return left_floor_ray_cast.is_colliding() and not left_wall_ray_cast.is_colliding()

# Ritorna true se almeno uno dei due attacchi è pronto 
func can_enemy_attack():
	if bush_guardian.melee_ready or bush_guardian.root_ready:
		return true
	return false
	
# In base alla disponibilità di attacchi viene scelto quale fare
func attack_behaviour() -> bool:

	# Root ha priorità se siamo fuori melee
	if bush_guardian.root_ready and player_in_range(pull_range) and not player_in_range(melee_range):
		transition.emit(self, "rootattack")
		return true

	# Melee solo se siamo davvero in melee range
	if bush_guardian.melee_ready and player_in_range(melee_range):
		transition.emit(self, "attack1")
		return true

	return false



func player_in_range(area : Area2D) -> bool:
	if player == null:return false
	var collision_shape := area.get_node("Shape") as CollisionShape2D
	if collision_shape == null: return false
	var circle := collision_shape.shape as CircleShape2D
	if circle == null: return false
	return owner_enemy.global_position.distance_to(player.global_position) <= circle.radius
