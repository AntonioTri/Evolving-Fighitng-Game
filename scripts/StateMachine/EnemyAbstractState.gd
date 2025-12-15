class_name EnemyAbstractState
extends Node

signal transition
var player : Player
var owner_body : AbstractEnemy
var sprite : Sprite2D
var animator : AnimationPlayer

func on_process(_delta: float) -> void:
	pass

func on_physics_process(_delta: float) -> void:
	pass

func enter() -> void:
	pass

func exit() -> void:
	pass

func get_player() -> Player:
	return get_tree().get_nodes_in_group("player")[0]
