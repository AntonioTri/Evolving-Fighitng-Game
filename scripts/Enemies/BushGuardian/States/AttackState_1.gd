extends EnemyAbstractState

var bush_guardian : BushGuardian
# Questa variabile conserva l'id globale dell'attacco in modo da poterlo 
# eliminare dalla que di dodge possibili o di parry possibili quando finisce
var attack_id : int 
@onready var melee_range: Area2D = $"../../AttackRanges/MeleeRange"
@onready var attack_box: CollisionBox = $"../../CollisionBoxes/AttackBox"

var lock_process : bool = false

# nella funzione process gestiamo gli attacchi, le distanze e le animazioni
func on_process(_delta: float) -> void:

	# Riga importantissima, lo stato è in mutua esclusione, fin quando l'animazione non è finta
	# il nemico rimane in questo stato in attesa di finire l'animazione
	if lock_process: return

	# Recupero del riferimento al player
	player = get_player()

	# Caso di sicurezza: il player non esiste più (morto, despawnato, uscito dall’area)
	# In questo caso si ritorna allo stato di patrolling
	if player == null:
		transition.emit(self, "patrolling")
		return

	# Se il guardiano non vede più il player, torna immediatamente in patrolling
	if not bush_guardian.can_see_player:
		transition.emit(self, "patrolling")
		return

	# Se vede il player ma questo NON è in range melee
	# Qui decidiamo se inseguirlo o attendere il cooldown
	if not player_in_melee_range():
		# Torna allo stato di chaising
		transition.emit(self, "chaising")
		
	# Altrimenti resta fermo e gioca l'animazione di idle
	# Protezione per evitare di riavviare l'animazione ogni frame
	elif player_in_melee_range() and not bush_guardian.melee_ready and animator.current_animation != "idle": 
		animator.play("idle")
		return
		

	# Se il guardiano può attaccare lo fa
	if bush_guardian.melee_ready and player_in_melee_range():
		bush_guardian.melee_used() 	# Ovviamente viene segnalato alla root che l'attacco è stato fatto
		lock_process = true			# Ovviamente pt2, blocchiamo la process
		animator.play("attack_1")
		return

func on_physics_process(_delta: float) -> void:
	pass

# All'ingresso nello stato viene fatto un casting della reference del nemico
# a quella del nemico BushGuardian in quanto lo stato è peculiare di questo nemico
func enter() -> void:
	var body = owner_enemy.get_type_reference()
	if body is BushGuardian:
		bush_guardian = body as BushGuardian

func exit() -> void:
	pass


# Questa funzione viene chiamata dall'animation manager per provare a concatenare la combo
func try_to_combo():
	# Semplicemente se il nemico può ancora vedere il player e questo è ancora in range melee
	# viene fatto partire lo stato di attacco 2
	if bush_guardian.can_see_player and player_in_melee_range():
		lock_process = false # Sblocchiamo la process
		transition.emit(self, "attack2")


func player_in_melee_range() -> bool:
	if player == null:return false
	var collision_shape := melee_range.get_node("Shape") as CollisionShape2D
	if collision_shape == null: return false
	var circle := collision_shape.shape as CircleShape2D
	if circle == null: return false
	return owner_enemy.global_position.distance_to(player.global_position) <= circle.radius


func add_attack_to_dodgable():
	# Registriamo l'id dell'attacco
	attack_id = AttackEmitter.announce_attack(owner_enemy, attack_box, attack_box.damage, true, true)

func remove_attack_from_dodging_list():
	# Usando l'id dell'attacco lo eliminiamo dalla coda degl attacchi schivabili o parriabili
	AttackEmitter.remove_attack(attack_id)

func porcodio():
	pass

# Alla fine dell'animazione la process viene sbloccata per continuare i behaviour
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack_1":
		lock_process = false
