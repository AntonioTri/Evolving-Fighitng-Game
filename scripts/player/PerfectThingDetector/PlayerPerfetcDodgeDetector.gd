# PlayerPerfectDodgeDetector.gd
class_name PlayerPerfectDodgeDetector
extends Node

# La variabile export che definisce il tempo in millisecondi per un dodge perfetto
@export var perfect_dodge_window_ms := 120
@onready var hurt_box: CollisionBox = $"../CollisoinBoxes/HurtBox"

# Gli attacchi registrati
var dodgiable_attacks: Dictionary[int, AttackEvent] = {}

# La funzione per registrare un attacco
func register_attack(event: AttackEvent):
	print("Attacco registrato. Tempo: ", Time.get_ticks_msec())
	dodgiable_attacks[event.id] = event

func remove_attack_from_queue(attack_id : int):
	print("Attacco rimosso dalla lista. Tempo: ", Time.get_ticks_msec())
	dodgiable_attacks.erase(attack_id)

# Questa funzione controlla se ci sono attacchi in arrivo nella finestra di tempo
# di dodge perfetto
func can_perfect_dodge() -> bool:
	var now := Time.get_ticks_msec()

	for id in dodgiable_attacks.keys():
		var event := dodgiable_attacks[id]
		if not event.can_be_perfect_dodged: continue
		
		# Se l'attacco è nella finestra di tempo giusta e avrebbe colpito il player, il dodge viene rilevato come perfetto
		if now - event.timestamp <= perfect_dodge_window_ms and check_overlap(hurt_box, event.attack_box):
			print("Dodge perfetto TROVATO ")
			return true # ritorna True se esiste un attacco dodgiabile perfettamente
	
	print("Dodge perfetto NON TROVATO ")
	return false # Ritorna false altrimenti


# Controlla se due Area2D si sovrappongono, anche se una (o entrambe) sono disabilitate.
# area_a: L'area attiva (es. Hurtbox Player)
# area_b: L'area disattivata (es. Hitbox Nemico)
func check_overlap(area_a: Area2D, area_b: Area2D) -> bool:
	# 1. Recuperiamo le CollisionShape2D (assumendo ce ne sia una per area)
	var shape_a_node = area_a.get_child(0) as CollisionShape2D
	var shape_b_node = area_b.get_child(0) as CollisionShape2D
	
	if not shape_a_node or not shape_b_node:
		push_warning("Una delle aree non ha un nodo CollisionShape2D come primo figlio.")
		return false

	# 2. Otteniamo lo stato dello spazio fisico
	var space_state = area_a.get_world_2d().direct_space_state
	
	# 3. Prepariamo i parametri per la query basandoci sulla forma dell'area B (quella del nemico)
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape_b_node.shape
	query.transform = shape_b_node.global_transform
	
	# 4. Limitiamo il controllo solo all'Area A (quella del player) 
	# per essere sicuri di non colpire altre aree casuali nel mondo.
	query.collide_with_areas = true
	query.collide_with_bodies = false
	
	# Usiamo l'ID dell'area_a come filtro (così cerchiamo SOLO quella)
	# Nota: intersect_shape di solito controlla contro tutto ciò che è nella mask,
	# ma noi vogliamo sapere specificamente se tocca l'area del player.
	var results = space_state.intersect_shape(query)
	
	for result in results:
		if result.collider == area_a:
			return true
	
	return false
