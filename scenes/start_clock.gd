extends Node

func run_script():
	var time_keeper = get_tree().get_first_node_in_group("time_keeper")
	time_keeper.unlock_time()
	var player_ref = get_tree().get_first_node_in_group("player")
	player_ref.show_hearts()
	player_ref.show_money()
	
