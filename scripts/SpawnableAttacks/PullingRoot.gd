extends SpawnableAttack

func	 _ready():
	super._ready()

func do_post_animation_behaviour():
	print("Pulling attack ended")

func affect_player(player: Player):
	
	var start := player.global_position
	var end := global_position  # posizione del nemico
	var duration := 0.35        # tempo del pull

	# Stunniamo il player per impedire movimenti ed interazioni
	player.get_stunned()

	# Flashamo il player
	player.flash_white(0.1)

	var t := 0.0
	while t < 1.0:
		t += get_process_delta_time() / duration
		t = clamp(t, 0.0, 1.0)

		# interpolazione base
		var pos := start.lerp(end, t)

		# arco parabolico (altezza)
		var height := -4.0 * pow(t - 0.5, 2) + 1.0
		pos.y -= height * 80.0

		player.global_position = pos
		await get_tree().process_frame

	# Riconsegniamo al player la libertà di movimento
	player.remove_stun()
