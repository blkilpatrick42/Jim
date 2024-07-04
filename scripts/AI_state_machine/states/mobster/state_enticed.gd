class_name Enticed_State
extends State

signal set_nav_target(pos : Vector2)
signal advance_navigation
signal set_target(target : Node)
signal pick_up(node: Node)
signal reduce_health()
signal pizza_bubble()
signal stop_movement()

var nav_target_reached = false
var host_position
var pizza_ref : Node = null

func get_host_position():
	return ai_state_machine.get_perceptions().position

func get_host_nav_target_reached():
	return ai_state_machine.get_perceptions().nav_target_reached

func process(_delta: float) -> void:
	pass

func handle_sparks():
	if(ai_state_machine.get_perceptions().colliding_nodes.size() > 0):
		for node in ai_state_machine.get_perceptions().colliding_nodes:
				if(is_instance_valid(node) && node.is_in_group("spark")):
					if(node.is_in_group(ai_state_machine.get_perceptions().opposing_team) &&
					!ai_state_machine.get_perceptions().invincible):
						reduce_health.emit()
						var assailant_obj = node.get_source_obj()
						set_target.emit(assailant_obj)
						if(ai_state_machine.get_perceptions().has_line_of_sight_to_target):
							ai_state_machine.transition_to(ai_state_machine.exclaiming)
							#TODO: else: flee!
						return true
					elif(!ai_state_machine.get_perceptions().invincible &&
					 !node.is_in_group(ai_state_machine.get_perceptions().opposing_team)):
						ai_state_machine.transition_to(ai_state_machine.falling)
						return true
	return false

func handle_death():
	if(ai_state_machine.get_perceptions().hit_points <= 0):
		ai_state_machine.transition_to(ai_state_machine.falling)
		return true
	return false

func physics_process(_delta: float) -> void:
	#check for knockout
	if(handle_sparks()):
		return
	elif(handle_death()):
		return
	else:
		#check for targets
		var player = get_tree().get_first_node_in_group("player")
		var nodes_in_vision = ai_state_machine.get_perceptions().nodes_in_vision
		var nodes_in_hearing = ai_state_machine.get_perceptions().nodes_in_hearing
		for node in nodes_in_vision:
			if(node != null && node.is_in_group(ai_state_machine.get_perceptions().opposing_team) &&
			node.is_in_group("mobster")):
				set_target.emit(node)
				if(ai_state_machine.get_perceptions().has_line_of_sight_to_target):
					ai_state_machine.transition_to(ai_state_machine.exclaiming)
					return
		if(nodes_in_vision.has(player)):
			set_target.emit(player)
			if(ai_state_machine.get_perceptions().has_line_of_sight_to_target):
				ai_state_machine.transition_to(ai_state_machine.exclaiming)
		elif(nodes_in_hearing.size() > 0):
			for node in nodes_in_hearing:
				if(node.is_in_group("exclaim")):
					var source_obj = node.get_source_obj()
					if(source_obj.is_in_group(ai_state_machine.get_perceptions().opposing_team)):
						set_target.emit(source_obj)
						ai_state_machine.transition_to(ai_state_machine.exclaiming)
						return
		#enticed code
		else:
			if(pizza_ref != null && 
			!pizza_ref.is_picked_up() &&
			ai_state_machine.perceptions.reactive_has_line_of_sight_to_target):
				nav_target_reached = get_host_nav_target_reached()
				if(!nav_target_reached):
					advance_navigation.emit(125000)
				else:
					if(!pizza_ref.is_picked_up()):
						pick_up.emit(pizza_ref)
						ai_state_machine.transition_to(ai_state_machine.returning) 
					else:
						stop_movement.emit()
						ai_state_machine.transition_to(ai_state_machine.look)
			else:
				stop_movement.emit()
				ai_state_machine.transition_to(ai_state_machine.look)

func enter(_msg := {}) -> void:
	pizza_bubble.emit()
	pizza_ref = get_tree().get_first_node_in_group("pizza")
	set_nav_target.emit(pizza_ref.global_position)
	set_target.emit(pizza_ref)

func exit() -> void:
	pass
	
