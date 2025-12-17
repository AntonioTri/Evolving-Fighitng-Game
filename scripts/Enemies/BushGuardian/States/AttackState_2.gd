extends EnemyAbstractState

# Stato di ATTACK_2
# Questo stato rappresenta il secondo colpo della combo melee.
# Non prende decisioni: riproduce l'animazione e, alla fine,
# ritorna sempre allo stato di patrolling.
# L'unica eccezine viene fatta per controllare se il player sia ancora in melee range
# in tal caso si torna allo stato di attacco 1 

@onready var melee_range: Area2D = $"../../AttackRanges/MeleeRange"

func on_process(_delta: float) -> void:
	# Nessuna logica di decisione durante l'animazione.
	# L'attacco è in mutua esclusione fino al termine.
	pass

func on_physics_process(_delta: float) -> void:
	# Nessun movimento durante l'attacco.
	# Eventuali forze o root motion vanno gestite dall'animazione.
	pass

func enter() -> void:
	player = get_player()
	# Avvio dell'animazione del secondo attacco
	animator.play("attack_2")

func exit() -> void:
	# Stato pulito: nessun flag da resettare qui
	pass

# Callback chiamata automaticamente dall'AnimationPlayer
# quando un'animazione termina
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	
	# Controllo di sicurezza: reagiamo solo se è terminata l'animazione corretta
	if anim_name != "attack_2":
		return
	
	# Al termine del secondo attacco se il player è ancora in range melee
	# si torna allo stato di attacco 1m altrimenti a patrolling
	if player_in_melee_range():		
		print("Attack 2 finito, player ancora IN range. Ritorno allo stato di attacco 1.")
		transition.emit(self, "attack1")
	else:
		print("Attack 2 finito, player NON in range. Ritorno a patrolling")
		transition.emit(self, "patrolling")


func player_in_melee_range() -> bool:
	if player == null:return false
	var collision_shape := melee_range.get_node("Shape") as CollisionShape2D
	if collision_shape == null: return false
	var circle := collision_shape.shape as CircleShape2D
	if circle == null: return false
	return owner_enemy.global_position.distance_to(player.global_position) <= circle.radius
