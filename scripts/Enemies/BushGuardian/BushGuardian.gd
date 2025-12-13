extends AbstractEnemy
class_name BushGuardian

@onready var animator: AnimationPlayer = $AnimationPlayer

# Funzione overraidata per gestire le interazioni non di natura fisica
func react():

	match state:
		
		
		EnemyState.ATTACKING:
			animator.play("attack_1")
		
		
		EnemyState.DYING:
			die()
		
		
		EnemyState.PARRIED:
			animator.play("parried")
		
		
		EnemyState.STUNNED:
			animator.play("stunned")
		
		
		EnemyState.ROTATING:
			change_direction()


# La funzione che gestisce la morte della entità
func die():
	
	make_invulnerable()
	animator.play("die")



# Quando il nemico ruota gli viene impedito il movimento e l'attacco
func change_direction():
	can_move = false
	can_attack = false
	if animator.current_animation != "rotate":
		animator.play("rotate")


# L'unica implementata è quella di patrolling che generalmente funziona uguale per tutti i nemici
func patrolling():

	if animator.current_animation != "walk":
		sprite.flip_h = ( direction == Direction.LEFT )
		animator.play("walk")

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


# Segnale di fine animazione per gestire i comportamenti legati ad esse
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	
	print("Animation finished: ", anim_name)
	
	match anim_name:
		
		"die": # Dopo che l'animazione è finita il nodo viene rimosso dalla scena
			print("Rimozione dalla scena")
			queue_free()
			
		"rotate": # Quando ha finito di ruotare il movimento e l'attacco gli vengono ridati
			print("Rotation finished")
			can_move = true
			can_attack = true
			# In base alla direzione viene ruotato lo sprite alla fine della animazione
			update_state(EnemyState.PATROLLING)
