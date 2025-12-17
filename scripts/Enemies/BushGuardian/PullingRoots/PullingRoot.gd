extends SpawnableAttack

@export var knockback_force : float
@export var knockback_angle_degree : int

func _ready(): 
	super._ready()
	if knockback_angle_degree >= 90 : knockback_angle_degree = 90

func do_post_animation_behaviour(): pass

func affect_player(player: Player):
	# Lock per impedire che l'effetto venga applicato più volte (spostato qui)
	is_effect_applayable = false

	# Estrazione della direzione
	var direction = find_direction_relative_to_player(player)
	# Chiamata la metodo del player per applicare il knockback
	player.gain_knockback(knockback_force, knockback_angle_degree, direction)
	# Tenicamente dovrebbe anche subire del danno
	# player.take_damage(root_damage)
	
	
