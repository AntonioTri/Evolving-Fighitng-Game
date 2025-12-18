# AttackAnnouncer.gd
class_name AttackAnnouncer
extends Node

# Questa classe annuncia un attacco in arrivo, alla chiamata di funzione
# Vengono definiti l'entità proprietaria, la attackbox, il danno e se può essere parriata o dodgiata perfettamente
signal attack_announced(event: AttackEvent)
signal attack_ended(attack_id : int)

# La funzinoe restituisce l'id dell'attacco così da poterlo eliminare dalla queue quando finisce la finestra di dodge
func announce_attack(
	source: AbstractEntity, 
	attack_box: CollisionBox, 
	damage: int, 
	can_be_perfect_dodged := true, 
	can_be_parried := true) -> int:
	
	# Definizione dell'evento di attacco
	var event := AttackEvent.new( source, attack_box, damage, can_be_perfect_dodged, can_be_parried )
	# Emissione dell'evento che il player cattura
	attack_announced.emit(event)
	# Ritorno dell'id
	return event.id

# Questa funzione emette il segnale globale per far eliminare dal dodge manager 
# del player l'attacco dalla queue di attacchi dodgiabili
func remove_attack(attack_id : int):
	attack_ended.emit(attack_id)
