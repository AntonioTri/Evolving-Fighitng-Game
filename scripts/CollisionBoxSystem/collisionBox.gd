extends Area2D
class_name CollisionBox

# Tipo della collision box
enum BoxType {
	HURTBOX,
	ATTACKBOX,
	PARRY
}

# Variabili export che aiutano a settare i dettagli interni dall'ispettore
@export var owner_entity: AbstractEntity
@export var box_type: BoxType
@export var damage : int
var is_perfect_parriable : bool

# La funzione ready collega al segnale area_entered la funzione handler per la collisione
func _ready() -> void:
	connect("area_entered", _on_area_entered)


# Funzione generale per gestire le collisioni
func _on_area_entered(box: Area2D) -> void:
	# Controlliamo se sia una CollisionBox
	if box is not CollisionBox:
		return

	# Puntatore tipizzato, obbligatorio in quanto non vi è un referencing 
	# tipizzato nella chiamata del segnale
	var cbox := box as CollisionBox

	if self.box_type == BoxType.HURTBOX and cbox.box_type == BoxType.ATTACKBOX:
		hurt_owner(cbox.owner_entity, cbox.damage)
	elif self.box_type == BoxType.PARRY and cbox.box_type == BoxType.ATTACKBOX:
		parry_entity(cbox.owner_entity, cbox.is_perfect_parriable)
	else:
		print("Collision detected")


# Handler per far prendere danno al proprietario della HurtBox
func hurt_owner(entity : AbstractEntity, damage_to_gain : int):
	
	# Rimozione del fuoco amico tra i nemici
	if entity is AbstractEnemy:
		var enemy = entity as AbstractEnemy
		if enemy == owner_entity: return
	
	if entity is Player:
		var giocatore = entity as Player
		if giocatore == owner_entity: return
	
	# Frame Freeze
	if damage_to_gain >= 10:
		GlobalF.hitstop(0.0, 0.1)

	if owner_entity:
		owner_entity.take_damage(damage_to_gain)
	else:
		print("Gaining Damage: ", damage_to_gain)


# Handler per staggerare l'entità parriata
func parry_entity(entity : AbstractEntity, parried_perfectly : bool):
	
	if entity is Player:
		var player = entity as Player
		player.get_parried()
	elif entity is AbstractEnemy:
		var enemy = entity as AbstractEnemy
		enemy.get_parried_with_damage(damage, parried_perfectly)
	else:
		print("Dummy parried")


func set_damage(value : int):
	if box_type == BoxType.ATTACKBOX:
		self.damage = value

func add_perfetc_parry():
	is_perfect_parriable = true

func remove_perfect_parry():
	is_perfect_parriable = false
