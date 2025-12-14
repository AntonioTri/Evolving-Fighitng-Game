extends Node2D
class_name ComboSystem

@export var first_attack: ComboAttack
@export var animator : AnimationPlayer = null
@onready var player: Player = $".."

var current_attack: ComboAttack = null
var queued_attack: ComboAttack = null
var can_chain := false
var in_recovery := false


# La funzione update controlla gli input direzionali per girare le hitbox nella direzione giusta
func update():
	self.scale.x = -1 if player.inputs.direction < 0 else 1

# Con la funzione start_combo si inizia una nuova combo o si tenta di concatenare un attacco
func start_combo():

	# Caso in cui non stiamo attaccando → primo attacco della combo
	if current_attack == null:
		make_first_attack()
		return

	# Se stiamo già attaccando → tentiamo concatenazione
	if can_chain and current_attack.next_attack and not in_recovery:
		enqueue_next_attack()

# Funzione per eseguire il primo attacco della combo
func make_first_attack():
	_reset_combo_state()
	# Impediamo al giocatore di muoversi
	player.states.block_movement()
	# Primo colpo
	current_attack = first_attack
	play_attack()




func play_attack():
	can_chain = false
	in_recovery = false
	animator.play(current_attack.animation_name)
	print("Attacco : ", current_attack.animation_name)


func animation_ended() :
	if queued_attack != null:
		return

	_reset_combo_state()
	player.states.allow_movement()


func start_recovery():
	in_recovery = true
	# Se abbiamo premuto al tempo giusto per concatenare ci sarà il prossimo attacco in coda:
	if queued_attack != null:
		current_attack = queued_attack
		queued_attack = null
		play_attack()   # SKIP recovery e passa al prossimo colpo


func _reset_combo_state():
	current_attack = null
	queued_attack = null
	can_chain = false
	in_recovery = false


func enable_chain():
	can_chain = true


func enqueue_next_attack():
	queued_attack = current_attack.next_attack


func allow_player_movement():
	player.states.allow_movement()
