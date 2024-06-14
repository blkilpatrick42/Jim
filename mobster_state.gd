#class_name Mobster_State
#extends State
#
#signal set_target(target : Node)
#
#func check_vision_for_targets() -> bool:
	#var player = get_tree().get_first_node_in_group("player")
	#var nodes_in_vision = ai_state_machine.get_perceptions().nodes_in_vision
	#for node in nodes_in_vision:
		#if(node.is_in_group(ai_state_machine.get_perceptions().opposing_team)):
	#if(nodes_in_vision.has(player)):
		#set_target.emit(player)
		#if(ai_state_machine.get_perceptions().has_line_of_sight_to_target):
			#ai_state_machine.transition_to(ai_state_machine.exclaiming)
		#return true
	#return false
