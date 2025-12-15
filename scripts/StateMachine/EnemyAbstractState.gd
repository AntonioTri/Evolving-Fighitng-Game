extends AbstractState
class_name EnemyAbstractState

var player : Player
var owner_enemy : AbstractEnemy

func get_player() -> Player:
	return get_tree().get_nodes_in_group("player")[0]
