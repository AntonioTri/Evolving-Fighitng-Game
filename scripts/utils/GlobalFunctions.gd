extends Node
class_name GlobalFX

var original_time_scale := 1.0

# Direzioni standardizzate


# funzione di hitstop
func hitstop(scale: float = 0.0, duration: float = 0.05):
	Engine.time_scale = scale
	
	await get_tree().create_timer(duration, true, false, true).timeout
	
	Engine.time_scale = original_time_scale
