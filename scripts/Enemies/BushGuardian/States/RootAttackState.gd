extends EnemyAbstractState

var bush_guardian : BushGuardian
@export var root_attack: PackedScene
@export var ROOT_X_OFFSET: float = 50.0

var attack_spawned: bool = false

func on_process(_delta: float) -> void:
	# Stato completamente lockato durante l'animazione
	pass

func on_physics_process(_delta: float) -> void:
	# Nessun movimento durante l'attacco
	pass

func enter() -> void:
	var body = owner_enemy.get_type_reference()
	if body is BushGuardian:
		bush_guardian = body as BushGuardian
	
	attack_spawned = false
	bush_guardian.root_used()
	animator.play("root_grab_attack")

func exit() -> void:
	attack_spawned = false

func spawn_root_attack() -> void:
	if attack_spawned: return
	if root_attack == null: return

	attack_spawned = true

	var r_attack: Node2D = root_attack.instantiate()

	# Posizione base
	r_attack.global_position = owner_enemy.global_position

	# Snap a terra
	var space := owner_enemy.get_world_2d().direct_space_state
	var from := owner_enemy.global_position
	var to := from + Vector2.DOWN * 2000

	var query := PhysicsRayQueryParameters2D.create(from, to)
	query.exclude = [owner_enemy]

	var result := space.intersect_ray(query)
	if result:
		r_attack.global_position.y = result.position.y

	# Offset e flip in base alla direzione
	if owner_enemy.direction == Direction.LEFT:
		r_attack.scale.x = -1
		r_attack.global_position.x += ROOT_X_OFFSET
	else:
		r_attack.scale.x = 1
		r_attack.global_position.x -= ROOT_X_OFFSET

	get_tree().current_scene.add_child(r_attack)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "root_grab_attack":
		transition.emit(self, "patrolling")
