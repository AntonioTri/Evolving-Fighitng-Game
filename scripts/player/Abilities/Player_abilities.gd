# PlayerAbilities.gd
extends Node
class_name Abilities

@onready var player_abilities: Abilities = $"."

var has_dash := false
var has_teleport := false
var has_perfect_parry := false
