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

# Funzione che gestisce la logica di danno
func take_damage(value : int):
	
	print("Enemy taking damage")
	# Viene skippato tutto se l'entità sta morendo
	if invulnerability or not is_player_visible():
		return
	print("Test1")
	# Hit flashper feedback
	flash_white(0.1)
	print("Test2")
	if health - value <= 0:
		# L'entità viene resa invulnerabile per darle il tempo di morire
		# Anche per evitare dei possibili bug
		make_invulnerable()
		# Viene anche impostata la flag per l'attacco a false per impedire bug
		print("Enemy "+ str(enemy_type) + " dieing.")
	
	else:
		health -= value
		print("Enemy "+ str(enemy_type) + " got damaged with " + str(value) + " damage. Current health: " + str(health))


# Hit flash per qunado un nemico viene colpito
func flash_white(duration := 0.1):
	
	var mat := $Sprite2D.material as ShaderMaterial
	if mat == null:
		return

	mat.set_shader_parameter("flash_strength", 1.0)
	var tween := get_tree().create_tween()
	tween.tween_property(mat, "shader_parameter/flash_strength", 0.0, duration )


# Quando questa funzione viene chiamata viene sottratto un parry necessario allo stunn
# se siamo a 0 il nemico viene stunnato
func get_parried_with_damage(value : int):
	# Per prima cosa controlliamo se col danno preso il nemico deve morire
	# in tal caso la funzione take_damage finirà l'handler da sola
	take_damage(value)
	
	# Banale logica di parry
	if stun_parry_needed > 0:
		stun_parry_needed -= 1
	else:
		get_stunned()
	print("Enemy got parried.")

func get_type_reference():
	pass
