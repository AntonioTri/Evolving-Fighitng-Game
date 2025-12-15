extends AbstractEnemy
class_name BushGuardian


@export var melee_attack_cd : float
@export var root_attack_cd : float
var melee_attack_timer : float = 0.0
var root_attack_timer : float = 0.0
var melee_ready : bool = false
var root_ready : bool = false


# La funzione process gestisce i cooldown interni in modo da renderli globali
func _process(delta: float) -> void:

	if melee_attack_timer <= melee_attack_cd: 	melee_attack_timer += delta
	else: 										melee_ready = true

	if root_attack_timer <= root_attack_cd: 	root_attack_timer += delta
	else: 										root_ready = true

# Queste funzioni vengono usate per segnalare nel nemico il fatto che abbia usato un attacco
# rimandandolo in cooldown
func melee_used():
	melee_attack_timer = 0.0
	melee_ready = false

func root_used():
	root_attack_timer = 0.0
	root_ready = false

# Questa funzione ritorna una reference di se stessi tipizzata
# Override della funzione della classe madre. Ogni nemico deve farla
func get_type_reference() -> BushGuardian:
	return self

# I due segnali attivano la flag per l'aggiornamento del raycasting
func _on_sight_of_view_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body as Player
		player_in_range_of_view = true


func _on_sight_of_view_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = null
		can_see_player = false
		player_in_range_of_view = false
