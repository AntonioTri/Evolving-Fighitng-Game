extends Node
class_name StateManager

@onready var player : Player = $".."

var stunned : bool = false
var can_mov : bool = true
var _can_attack : bool = true
var can_dash : bool = false
var walking : bool = false
var running : bool = false
var attacking : bool = false

func apply_stun():
	stunned = true

	can_mov = false
	_can_attack = false
	can_dash = false

	walking = false
	running = false

func remove_stun():
	stunned = false

	can_mov = true
	_can_attack = true
	# can_dash dipende dalle abilità, non dallo stun

func allow_movement():
	can_mov = true

func block_movement():
	can_mov = false

func allow_attack():
	_can_attack = true

func block_attack():
	_can_attack = false

func allow_dash():
	can_dash = true

func block_dash():
	can_dash = false

func set_walking():
	if not can_move:
		return

	walking = true
	running = false

func set_running():
	if not can_move:
		return

	running = true
	walking = false

func stop_movement():
	walking = false
	running = false

func can_move() -> bool:
	return not stunned and can_mov

func is_moving() -> bool:
	return walking or running

func is_walking() -> bool:
	return walking

func is_running() -> bool:
	return running

func is_stunned() -> bool:
	return stunned

func can_attack() -> bool:
	return _can_attack

func is_attacking() -> bool:
	return attacking

func set_attacking():
	attacking = true

func stop_attacking():
	attacking = false
