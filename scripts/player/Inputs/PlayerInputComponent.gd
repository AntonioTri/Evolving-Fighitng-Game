class_name PlayerInputComponent extends Node

# Finestra di tempo in cui un input viene "ricordato" (in msec)
# 0.15s è un buon valore standard
@export var buffer_window: float = 0.15

# Timestamp dell'ultima volta che un tasto è stato premuto
var _last_jump_time: float = -1.0
var _last_dash_time: float = -1.0
var _last_attack_time: float = -1.0
var _last_parry_time: float = -1.0

# Direzione di movimento (non ha bisogno di buffer, serve quella attuale)
var direction: int = 0

func _physics_process(_delta):
	# Gestione Movimento
	var x_input = int(Input.get_axis("move_left", "move_right"))
	# In un sidescroller 2D solitamente la Y non serve per il movimento standard, 
	# ma se hai scale o altro aggiungila.
	direction = x_input

func _unhandled_input(event):
	# Usiamo _unhandled_input per catturare i click dei tasti
	# Salviamo IL MOMENTO in cui è avvenuto il click
	
	if event.is_action_pressed("jump"):
		_last_jump_time = Time.get_ticks_msec() / 1000.0
		
	if event.is_action_pressed("dash"):
		_last_dash_time = Time.get_ticks_msec() / 1000.0
		
	if event.is_action_pressed("attack"):
		_last_attack_time = Time.get_ticks_msec() / 1000.0
		
	if event.is_action_pressed("parry"):
		_last_parry_time = Time.get_ticks_msec() / 1000.0

# --- API PER GLI STATI ---

# Controlla se c'è un salto "in canna"
func is_jump_buffered() -> bool:
	return _is_action_buffered(_last_jump_time)

# Controlla se c'è un dash "in canna"
func is_dash_buffered() -> bool:
	return _is_action_buffered(_last_dash_time)

func is_attack_buffered() -> bool:
	return _is_action_buffered(_last_attack_time)

func is_parry_buffered() -> bool:
	return _is_action_buffered(_last_parry_time)

# Metodo privato di utility
func _is_action_buffered(timestamp: float) -> bool:
	var time_now = Time.get_ticks_msec() / 1000.0
	# Restituisce vero se il tempo passato dal click è minore del buffer
	return (time_now - timestamp) <= buffer_window

# --- CONSUMO DEGLI INPUT ---
# Fondamentale: Quando uno stato "usa" l'input, deve svuotare il buffer
# altrimenti al frame successivo l'input risulterebbe ancora valido.

func consume_jump():
	_last_jump_time = -1.0

func consume_dash():
	_last_dash_time = -1.0

func consume_attack():
	_last_attack_time = -1.0
	
func consume_parry():
	_last_parry_time = -1.0
