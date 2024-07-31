extends Node

@onready var _script_node = $script_node

@export var cost : int
@export var ware_name : String = ""

func buy_item():
	var player_ref = get_tree().get_first_node_in_group("player")
	player_ref._on_add_money(-cost)
	_script_node.run_script()

func get_ware_name() -> String:
	return ware_name

func get_cost() -> int:
	return cost

