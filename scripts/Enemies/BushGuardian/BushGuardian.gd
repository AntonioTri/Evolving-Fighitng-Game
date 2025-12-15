extends AbstractEnemy
class_name oldBushGuardian

@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var melee_range: Area2D = $AttackRanges/MeleeRange
@onready var pull_range: Area2D = $AttackRanges/PullRange


# Variabili per i cooldown degli attacchi
@export var root_attack : PackedScene
@export var attack_cd : float = 3.0
@export var root_attack_cd : float = 3.0
@export var pulling_force : float = 0

var attack_timer : float = 0.0
var root_attack_timer : float = 0.0
var melee_avaiable : bool = false
var pull_avaiable : bool = false
var ROOT_X_OFFSET : int = 10
var attack_step := 0
var combo_requested := false


func _ready() -> void:
	# Chiamata al ready della superclasse
	super._ready()
	# Inizializzazione del timer di attacco
	attack_timer = attack_cd

# La funzine process overraidata aiuta a tenere traccia del timer di attacco
# sia melee che del pull
func _process(delta: float) -> void:
	
	super._process(delta)

	# Aggiornamento del timer di attacco
	if attack_timer < attack_cd:
		attack_timer += delta
	if root_attack_timer < root_attack_cd:
		root_attack_timer += delta


# Funzione overraidata per gestire le interazioni non di natura fisica
func react():

	match state:
		
		
		EnemyState.ATTACKING:
			if can_attack:
				attack()
		

		EnemyState.DYING:
			die()
		
		
		EnemyState.PARRIED:
			animator.play("parried")
		
		
		EnemyState.STUNNED:
			animator.play("stunned")



func idleing():
	if animator.current_animation != "idle":
		animator.play("idle")


# La funzione che gestisce la morte della entità
func die():
	
	make_invulnerable()
	animator.play("die")


# Quando il nemico ruota gli viene impedito il movimento e l'attacco
func do_rotation():
	if animator.current_animation != "rotate":
		animator.play("rotate")


func attack_behavior():
	print("Enemy can attack!")
	block_movement()
	allow_attack()
	update_state(EnemyState.ATTACKING)


func attack():

	# Se un attacco era già stato scelto si continua ad aggiornare quello stato
	if in_melee_attack:
		melee_attack()
		return
	elif in_pull_attack:
		pull_attack()
		return

	# Altrimenti vengono fatti i calcoli per un attacco nuovo
	var can_melee := can_melee_attack()
	var can_pull := can_pull_attack()

	if not can_melee and not can_pull:
		return

	var choosed_attack := -1

	if can_melee and can_pull:
		choosed_attack = randi() % 2
	elif can_melee:
		choosed_attack = 0
	elif can_pull:
		choosed_attack = 1

	match choosed_attack:
		0:
			melee_attack()
		1:
			pull_attack()



var in_melee_attack := false
func melee_attack():

	in_melee_attack = true
	# Reset del timer di attacco
	attack_timer = 0

	# Concatenazione della combo se richiesta
	if attack_step == 0 and combo_requested:
		attack_step = 1
		combo_requested = false

	# Scelta dell'animazione di attacco in base al passo dell'attacco
	match attack_step:
		0:
			if animator.current_animation != "attack_1":
				animator.play("attack_1")
		1:
			if animator.current_animation != "attack_2":
				animator.play("attack_2")

var in_pull_attack := false
func pull_attack():
	in_pull_attack = true
	root_attack_timer = 0
	block_movement()
	allow_attack()
	update_state(EnemyState.ATTACKING)

	if animator.current_animation != "root_grab_attack":
		animator.play("root_grab_attack")



# Funzione per controllare se il player è attaccabile in uno dei due range
func is_player_attackable():
	if can_melee_attack() or can_pull_attack():
		return true


# Funzione per controllare se il player sia in range melee
func player_in_melee_range() -> bool:
	if player == null:
		return false
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if distance_to_player <= melee_range.get_node("Shape").shape.radius:
		return true
	
	return false


# Funzione per controllare se il player sia in range di pull
func player_in_pull_range() -> bool:
	if player == null:
		return false
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if distance_to_player <= pull_range.get_node("Shape").shape.radius:
		return true
	
	return false


func can_melee_attack() -> bool:
	return player_in_melee_range() and attack_timer >= attack_cd


func can_pull_attack() -> bool:
	return player_in_pull_range() and root_attack_timer >= root_attack_cd


func spawn_pull_attack():
	if root_attack == null:
		return

	var r_attack : Node2D = root_attack.instantiate()

	# Posizione X del nemico
	r_attack.global_position.x = global_position.x - 50

	# Snap a terra
	var space := get_world_2d().direct_space_state
	var from := global_position
	var to := from + Vector2.DOWN * 2000

	var query := PhysicsRayQueryParameters2D.create(from, to)
	query.exclude = [self]

	var result := space.intersect_ray(query)
	if result:
		r_attack.global_position.y = result.position.y
	else:
		r_attack.global_position.y = global_position.y
	
	if direction == -1:	
		r_attack.scale.x = -1
		r_attack.global_position.x = global_position.x + ROOT_X_OFFSET
	elif  direction == 1:
		r_attack.scale.x = 1
		r_attack.global_position.x = global_position.x - ROOT_X_OFFSET

	# viene aggiunto il nodo alla scena con le impostazioni giuste
	get_tree().current_scene.add_child(r_attack)

# Funzione per tentare di eseguire un combo di attacchi
# se il player è tropo lontano torna a muoversi verso di lui
# Vinee chiamata dall'animation manager durante l'animazione di attacco per concatenare correttamente
# le due animazioni 
func try_to_combo():
	if attack_step == 0 and player_in_melee_range():
		print("Combo window opened")
		combo_requested = true


# Segnale di fine animazione per gestire i comportamenti legati ad esse
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	
	print("Animation finished: ", anim_name)
	
	match anim_name:
		
		"die": # Dopo che l'animazione è finita il nodo viene rimosso dalla scena
			print("Rimozione dalla scena")
			queue_free()
			
		"rotate": # Quando ha finito di ruotare il movimento e l'attacco gli vengono ridati
			print("Rotation finished")
			should_flip_h = true # Viene segnalato alla fine dell'animazine che lo sprite dovrebbe ruotare
			update_state(status_pre_rotate)
			# In base alla direzione viene ruotato lo sprite alla fine della animazione
			allow_attack()
			allow_movement()
		
		"attack_1":
			if combo_requested or attack_step == 1:
				return # recovery cancellata
			in_melee_attack = false
			allow_movement()
			block_attack()
			update_state(EnemyState.CHAISING)

		"attack_2":
			attack_step = 0
			combo_requested = false
			in_melee_attack = false
			allow_movement()
			block_attack()
			update_state(EnemyState.CHAISING)
		
		"root_grab_attack":
			in_pull_attack = false
			allow_movement()
			block_movement()
			update_state(EnemyState.CHAISING)
