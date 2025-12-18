# AttackEvent.gd
class_name AttackEvent
extends RefCounted

# Questa classe permette di istanziare un attacco con le sue componenti
var source: AbstractEntity
var attack_box: CollisionBox
var damage: int
var can_be_perfect_dodged: bool
var can_be_parried: bool
var timestamp: float
var id: int

func _init(
	_source: AbstractEntity,
	_attack_box: CollisionBox,
	_damage: int,
	_can_be_perfect_dodged: bool,
	_can_be_parried: bool
):
	source = _source
	attack_box = _attack_box
	damage = _damage
	can_be_perfect_dodged = _can_be_perfect_dodged
	can_be_parried = _can_be_parried
	timestamp = Time.get_ticks_msec()
	id = randi()
