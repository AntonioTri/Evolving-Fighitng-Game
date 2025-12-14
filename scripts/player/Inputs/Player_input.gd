# PlayerInput.gd
extends Node
class_name PlayerInput

@onready var player: Player = $".."

# Variabili boolenae accessibili tramite il player per conoscere gl input globalmente
var direction := 0
var jump_pressed := false
var run_pressed := false
var dash_pressed := false

# La funzione update legge gli input ogni frame e aggiorna le variabili corrispondenti
func update():
	direction = int(Input.get_axis("move_left", "move_right"))
	jump_pressed = Input.is_action_just_pressed("jump") and player.is_on_floor()
	run_pressed = Input.is_action_pressed("run")
	dash_pressed = Input.is_action_just_pressed("dash")

	# Aggiorna l'ultima direzione orizzontale del player
	if direction != Direction.STILL:
		player.last_direction = direction
