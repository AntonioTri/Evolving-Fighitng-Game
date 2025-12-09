extends CharacterBody2D
class_name AbstractEntity

# Enumerazione che identifica le entità possibili
enum EntityType {
	PLAYER,
	ENEMY,
	PROJECTILE
}


# Il tipo di entità scelto
@export var entity_type : EntityType
# Il numero di parry necessari per uno stun
@export var stun_parry_needed : int = 0
# Velocità di movimento
@export var SPEED = 300.0
# Il valore in dell'entità
@export var health : int = 5

# Variabili booleane per conservare gli stati interni e gestire le logiche
var is_attacking : bool = false



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Questa funzione fighissima ed importantissima effettua timefreeze quando chiamata
func frame_freeze(timescale : float, duration : float) -> void:
	Engine.time_scale = timescale
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0
	
	
# funzione che gestisce la logica di danno
func take_damage(value : int):
	if health - value <= 0:
		die()
	else:
		health -= value
		print("Entity "+ str(entity_type) + " got damaged with " + str(value) + " damage. Current health: " + str(health))

# Funzione che gestisce lo stunn
func get_stunned():
	pass

# Funzione che gestisce lo status di parry
func get_parried():
	pass

# Gestione dei knockback 
func get_knockbacked():
	pass

# La funzione che gestisce la morte della entità
func die():
	print("Entity "+ str(entity_type) + " dying")
