extends AbstractEnemy
class_name BushGuardian

@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var melee_range: Area2D = $AttackRanges/MeleeRange
@onready var pull_range: Area2D = $AttackRanges/PullRange


# Variabili per i cooldown degli attacchi
@export var attack_cd : float = 3.0
var attack_timer : float = 0.0
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


# La funzione di attacco del Bush Guardian
func attack():
	
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



# Funzione per controllare se il player è attaccabile in uno dei due range
func is_player_attackable():
	if ( player_in_melee_range() or player_in_pull_range() ) and attack_timer >= attack_cd:
		return true


func attack_behavior():
	print("Enemy can attack!")
	block_movement()
	allow_attack()
	update_state(EnemyState.ATTACKING)


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


# Script dedicato per gestire il behavior
func do_walk_animation():
	if animator.current_animation != "walk":
		animator.play("walk")


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
			allow_movement()
			block_attack()
			update_state(EnemyState.CHAISING)

		"attack_2":
			attack_step = 0
			combo_requested = false
			allow_movement()
			block_attack()
			update_state(EnemyState.CHAISING)
