extends  Node2D
class_name SpawnableAttack

# Variabili da inserire durante la creazione della scena per lo spawnabile
@export var animator: AnimationPlayer
@export var sprite: Sprite2D
@export var effect_area: Area2D
@export var animation_name : StringName

var is_effect_applayable : bool = true


# La funzione readi quando l'oggetto è istanziato controlla se questo abbia tutte le componenti
# e poi avvia l'animazione, l'animator poi fa il resto
func _ready():

	if not animator or not sprite or not effect_area or animation_name == "":
		print("Spawnable attack is missing a key component. Removing from scene")
		queue_free()
		return

	else:
		
		animator.animation_finished.connect(_animation_finished)
		effect_area.body_entered.connect(_body_entered)

		animator.play(animation_name)


# Quando l'attacco finisce viene rimosso dalla scena dopo aver eseguito un comportamento di fine
# se implementato, altrimenti muore ebbasta
func _animation_finished(anim_name: StringName) -> void:
	
	# Funzione astratta da implementare nelle classi figlie
	do_post_animation_behaviour()
	if anim_name == animation_name:
		queue_free()

func _body_entered(body: Node2D) -> void:
	# Lock per impedire che a diversi stadi e forme della collision 
	# box il player subisca l'effetto più di una volta
	if body is Player and is_effect_applayable:
		is_effect_applayable = false 
		var player = body as Player
		# Funzione astratta da implementare nelle classi figlie
		affect_player(player)


# Funzione da implementare nelle classi figlie
func do_post_animation_behaviour():
	pass

# Funzione da implementare nelle classi figlie
func affect_player(_player : Player):
	pass
