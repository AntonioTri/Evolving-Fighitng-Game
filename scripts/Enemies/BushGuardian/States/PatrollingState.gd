extends EnemyAbstractState

@export var SPEED : float

# Reference al raycast per il movimento
@onready var right_wall_ray_cast: RayCast2D = $"../../RaycastingMovement/RightWallRayCast"
@onready var left_wall_ray_cast: RayCast2D = $"../../RaycastingMovement/LeftWallRayCast"
@onready var right_floor_ray_cast: RayCast2D = $"../../RaycastingMovement/RightFloorRayCast"
@onready var left_floor_ray_cast: RayCast2D = $"../../RaycastingMovement/LeftFloorRayCast"

@onready var vision_ray_cast: RayCast2D = $"../../SightOfView/RayCast2D"

var player_in_range : bool = false

func on_process(_delta: float) -> void:
	pass

func on_physics_process(_delta: float) -> void:
	
	# Durante il patrolling se il player è in range e visibile
	# Si attiva lo stato di chaising
	if owner_enemy.can_see_player:
		transition.emit(self, "chaising")
		return # Si esce dalla funzione per evitare qualsivoglia bug
	
	# Scelta della direzione in base al raycasting
	if owner_enemy.direction == Direction.RIGHT:
		if can_walk_right():
			# Applicazione del vettore velocità
			owner_enemy.velocity.x = SPEED
			# Funzione che muove il corpo della entity
			owner_enemy.move_and_slide()
		else:
			transition.emit(self, "rotating")
	
	elif owner_enemy.direction == Direction.LEFT:
		if can_walk_left():
			# Applicazione del vettore velocità
			owner_enemy.velocity.x = -SPEED
			# Funzione che muove il corpo della entity
			owner_enemy.move_and_slide()
		else:
			transition.emit(self, "rotating")


func enter() -> void:
	animator.play("walk")

func exit() -> void:
	animator.stop()


# Questa funzione ritorna true se il nemico può camminare a destra, altrimenti ritorna false
func can_walk_right() -> bool:
	return right_floor_ray_cast.is_colliding() and not right_wall_ray_cast.is_colliding()

# Questa funzione ritorna true se il nemico può camminare a destra, altrimenti ritorna false
func can_walk_left() -> bool:
	return left_floor_ray_cast.is_colliding() and not left_wall_ray_cast.is_colliding()
