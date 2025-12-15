extends EnemyAbstractState

@onready var guardian: AbstractEnemy = $"../.."

func on_process(_delta: float) -> void:
	pass

func on_physics_process(_delta: float) -> void:
	if guardian.is_on_floor():
		transition.emit(self, "patrolling")


func enter() -> void:
	animator.play("idle")

func exit() -> void:
	animator.stop()
