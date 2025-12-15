extends EnemyAbstractState

@onready var collision_boxes_root: Node2D = $"../../CollisionBoxes"

func on_process(_delta: float) -> void:
	pass

func on_physics_process(_delta: float) -> void:
	pass

func enter() -> void:
	animator.play("rotate")

func exit() -> void:
	animator.stop()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "rotate":
		# Orientamento corretto della direzione logica
		owner_enemy.direction = owner_enemy.direction * -1
		# Flip dello sprite
		sprite.flip_h = true if owner_enemy.direction == Direction.LEFT else false
		# Vengono ruotate anche le assi delle collisionbxes
		collision_boxes_root.scale.x = -1 if owner_enemy.direction < 0 else 1
		# Viene reimpostato lo stato pre rotazione
		transition.emit(self, "patrolling")
