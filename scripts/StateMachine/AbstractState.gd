extends Node
class_name AbstractState

var sprite : Sprite2D
var animator : AnimationPlayer
var owner_body : AbstractEntity

signal transition

func on_process(_delta: float) -> void:
	pass

func on_physics_process(_delta: float) -> void:
	pass

func enter() -> void:
	pass

func exit() -> void:
	pass
