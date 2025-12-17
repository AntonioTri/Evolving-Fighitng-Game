extends Node2D
class_name PlayerVisuals

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player: Player = $".."


func update(_delta):

	if player.inputs.direction == Direction.LEFT:
		sprite_2d.flip_h = true
	elif player.inputs.direction == Direction.RIGHT:
		sprite_2d.flip_h = false
	
	# Gestione delle animazioni in base allo stato del player
	if player.states.is_running():
		play_run_animation()
	elif player.inputs.direction != Direction.STILL:
		play_walk_animation()
	elif player.inputs.direction == Direction.STILL:
		play_idle_animation()


# Funzioni per gestire le animazioni del player in base al movimento
func play_idle_animation():
	if animation_player.current_animation != "idle":
		animation_player.play("idle")

func play_run_animation():
	if animation_player.current_animation != "run":
		animation_player.play("run")

func play_walk_animation():
	if animation_player.current_animation != "walk":
		animation_player.play("walk")
