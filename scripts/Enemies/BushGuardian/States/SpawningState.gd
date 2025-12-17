extends EnemyAbstractState

@export var gravity_force: float = 980.0
@onready var collision_boxes_root: Node2D = $"../../CollisionBoxes"

func on_process(_delta: float) -> void:
	pass

func on_physics_process(delta: float) -> void:
	if not owner_enemy.is_on_floor():
		owner_enemy.velocity.y += gravity_force * delta
		owner_enemy.move_and_slide()
	else:
		transition.emit(self, "patrolling")

# All'ingresso dello stato spawning viene decisa la direzione iniziale randomicamente, 
# ruotando di conseguenza sprite, box di collisioni e definendo la variabile globale
func enter() -> void:
	owner_enemy.direction = Direction.RIGHT if randi_range(0, 1) == 1 else Direction.LEFT
	sprite.flip_h = true if owner_enemy.direction == Direction.LEFT else false
	collision_boxes_root.scale.x = -1 if owner_enemy.direction < 0 else 1

func exit() -> void:
	pass
	
