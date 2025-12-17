extends Node
class_name PlayerProgression 

# Tipologie delle evoluzioni
enum SwordType { SWORD, FISTS }
enum DashType { NONE, DASH, BLINK }
enum ParryType { NONE, BASIC, EVOLVED, EVOLVED_EX }
enum JumpType { GROUNDED, DOUBLE_JUMP }

# Attuali evoluzioni
@export_group("Evolutions")
@export var current_sword : SwordType = SwordType.SWORD
@export var current_dash : DashType = DashType.NONE
@export var current_parry : ParryType = ParryType.NONE
@export var current_jump : JumpType = JumpType.GROUNDED 
@export var punch_crit_multiplier: float = 3.0

# Booleane per tenere traccia di possibili dash o blink perfetti
var dash_evolved : bool = false
var blink_evolved : bool = false


# ===== API per evolvere il dash su chiamata ===== #
func evolve_dash():
	
	# Evoluzione lineare.
	# 1. Se non ha il dash, viene assegnato il dash standard 
	# 2. Se ha il dash standard viene flaggato come evoluto
	# 3. Viene assegnato il Blink come dash standard
	# 4. Viene evoluto il blink per sbloccare il TPQTE
	
	if current_dash == DashType.NONE:
		current_dash = DashType.DASH
	
	elif current_dash == DashType.DASH and not dash_evolved:
		dash_evolved = true
	
	elif current_dash == DashType.DASH and dash_evolved:
		current_dash = DashType.BLINK
	
	elif current_dash == DashType.BLINK and not blink_evolved:
		blink_evolved = true


# ===== API per evolvere il dash su chiamata ===== #
func evolve_parry():
	
	# Evoluzione lineare, no parry -> normale -> evoluto -> tecnologia avanzata
	match current_parry:
		ParryType.NONE:			current_parry = ParryType.BASIC
		ParryType.BASIC:		current_parry = ParryType.EVOLVED
		ParryType.EVOLVED:		current_parry = ParryType.EVOLVED_EX
		ParryType.EVOLVED_EX: 	return
