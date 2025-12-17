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
# La reference allo spritesheet
@export var sprite : Sprite2D
# Il numero di parry necessari per uno stun
@export var stun_parry_needed : int = 0
# Il valore in dell'entità
@export var health : int = 5

# Variabili booleane per conservare gli stati interni e gestire le logiche
var invulnerability : bool = false
var current_parry_needed_for_stunn = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_parry_needed_for_stunn = stun_parry_needed

# Questa funzione fighissima ed importantissima effettua timefreeze quando chiamata
func frame_freeze(timescale : float, duration : float) -> void:
	Engine.time_scale = timescale
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0

# funzione che gestisce la logica di danno
func take_damage(value : int):
	
	# Se è invulnerabile l'entità non prende danno e non fa le animazioni
	if invulnerability:
		return
	
	if health - value <= 0:
		die()
	else:
		health -= value
		print("Entity "+ str(entity_type) + " got damaged with " + str(value) + " damage. Current health: " + str(health))


# Hit flash per quando una entità viene colpita
func flash_white(sprite: Sprite2D, duration := 0.1):
	
	var mat := sprite.material as ShaderMaterial
	if mat == null:
		return

	mat.set_shader_parameter("flash_strength", 1.0)
	var tween := get_tree().create_tween()
	tween.tween_property(mat, "shader_parameter/flash_strength", 0.0, duration )


# Gestione dei knockback 
func get_knockbacked():
	pass

func make_invulnerable():
	invulnerability = true

func remove_invulnerability():
	invulnerability = false

# La funzione che gestisce la morte della entità
func die():
	
	# L'entità viene anche resa invulnerabile per darle il tempo di morire
	# Anche per evitare dei possibili bug
	make_invulnerable()
	print("Entity "+ str(entity_type) + " dying")
	queue_free()
