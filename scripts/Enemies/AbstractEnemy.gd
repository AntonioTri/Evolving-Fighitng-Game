extends AbstractEntity
class_name AbstractEnemy

enum EnemyType {
	DUMMY,
	BUSH_GUARDIAN 
}

# Il tipo del nemico scelto da una enumerazione
@export var enemy_type : EnemyType
# Il valore dello scudo del nemico
@export var shield_amount : int = 0
# Il raycast di visione
@onready var vision_raycast: RayCast2D = $SightOfView/RayCast2D

var direction: int

# Segnali per eventi di stato hard o di assoluta priorità
signal died
signal parried
signal stunned


# Variabile che definisce se un nemico vede il player
var can_see_player : bool
var player_in_range_of_view : bool
var player : Player


func _physics_process(_delta: float) -> void:
	if player_in_range_of_view:
		update_vision_raycast()
		can_see_player = true if is_player_visible() else false


# La funzione aggiorna la posizione del raycasting verso il player
func update_vision_raycast():
	
	if player:
		# Direzione dal nemico al player
		var dir := player.global_position - global_position
		
		# Il RayCast2D vuole una posizione locale come target
		vision_raycast.target_position = dir
		vision_raycast.force_raycast_update()


# Invece questa funzione ci aiuta a capire se il vision raycast incrocia il player
func is_player_visible() -> bool:
	if player == null:return false
	
	vision_raycast.force_raycast_update()
	if not vision_raycast.is_colliding(): return false
	var hit := vision_raycast.get_collider()
	return hit == player

# Gestione del danno preso
func take_damage(value: int):
	print("Enemy taking damage")
	if invulnerability:
		return

	health -= value
	print("Enemy "+ str(enemy_type) + " got damaged with " + str(value) + " damage. Current health: " + str(health))
	
	# Hit flash per feedback
	flash_white(sprite, 0.2)

	if health <= 0:
		health = 0
		make_invulnerable()
		print("Enemy "+ str(enemy_type) + " dieing.")
		died.emit()


# Quando questa funzione viene chiamata viene sottratto un parry necessario allo stunn
# se siamo a 0 il nemico viene stunnato
func get_parried_with_damage(value: int, perfect: bool):
	# Per prima cosa controlliamo se col danno preso il nemico deve morire
	# in tal caso la funzione take_damage finirà l'handler da sola
	take_damage(value)

	if perfect:
		print("Enemy got parried PERFECTLY.")
		# Banale logica di parry
		stun_parry_needed -= 1
		
		# Se siamo al limite di parry perfetti subiti emittiamo lo stato di stun
		if stun_parry_needed <= 0:
			stunned.emit()
		# Altrimenti quello di parry
		else:
			parried.emit()

func find_direction_relative_to_player(play : Player):
	var start := play.global_position.x  # posizione del player
	var end := global_position.x  # posizione del nemico
	# Calcoliamo la direzione in cui spingere (Lontano dal nemico)
	return -1 if start > end else 1

func get_type_reference():
	pass
