class_name Chasing_State
extends State

var current_patrol_point :Node2D = null

signal set_nav_target(pos: Vector2)
signal advance_navigation(speed: int)
signal question_bubble
signal reduce_health()
signal set_target(target : Node)

var nav_target_reached = false
var setup_done = false
var host_position

func get_host_position():
	return ai_state_machine.get_perceptions().position

func get_host_nav_target_reached():
	return ai_state_machine.get_perceptions().nav_target_reached

func handle_sparks():
	if(ai_state_machine.get_perceptions().colliding_nodes.size() > 0):
		for node in ai_state_machine.get_perceptions().colliding_nodes:
			if(is_instance_valid(node) && node.is_in_group("bullet_spark")):
				#take damage when hit with bullet
				if(node.is_in_group(ai_state_machine.get_perceptions().opposing_team) &&
				!ai_state_machine.get_perceptions().invincible):
					reduce_health.emit()
					return true
				#knockout when player throws object
			elif(!ai_state_machine.get_perceptions().invincible &&
			 node.is_in_group("spark")):
				ai_state_machine.transition_to(ai_state_machine.falling)
				return true
	return false

func handle_death():
	if(ai_state_machine.get_perceptions().hit_points <= 0):
		ai_state_machine.transition_to(ai_state_machine.falling)
		return true
	return false

func process(_delta: float) -> void:
	pass

func physics_process(_delta: float) -> void:
	#check knockout
	if(handle_sparks()):
		return
	elif(handle_death()):
		return
	else:
		#mobster takes priority over player
		var player = get_tree().get_first_node_in_group("player")
		var nodes_in_vision = ai_state_machine.get_perceptions().nodes_in_vision
		var nodes_in_hearing = ai_state_machine.get_perceptions().nodes_in_hearing
		for node in nodes_in_vision:
			if(node != null && node.is_in_group(ai_state_machine.get_perceptions().opposing_team) &&
			node.is_in_group("mobster") && node != ai_state_machine.get_perceptions().target_obj &&
			!ai_state_machine.get_perceptions().has_line_of_sight_to_target):
				set_target.emit(node)
				if(ai_state_machine.get_perceptions().has_line_of_sight_to_target):
					ai_state_machine.transition_to(ai_state_machine.exclaiming)
					return
		if(ai_state_machine.get_perceptions().target_obj != null &&
		!ai_state_machine.get_perceptions().target_obj.is_in_group("player") &&
			nodes_in_vision.has(player)):
			set_target.emit(player)
			if(ai_state_machine.get_perceptions().has_line_of_sight_to_target):
				ai_state_machine.transition_to(ai_state_machine.exclaiming)
				return
		
		nav_target_reached = get_host_nav_target_reached()
		if(!nav_target_reached):
			advance_navigation.emit(400000)
		else:
			if(!ai_state_machine.get_perceptions().has_line_of_sight_to_target):
				#question_bubble.emit()
				ai_state_machine.transition_to(ai_state_machine.look)
				return
				
		if(ai_state_machine.get_perceptions().has_line_of_sight_to_target):
			ai_state_machine.transition_to(ai_state_machine.strafing)

func enter(_msg := {}) -> void:
	var last_seen_pos = ai_state_machine.get_perceptions().target_pos
	set_nav_target.emit(last_seen_pos)

func exit() -> void:
	pass
	
