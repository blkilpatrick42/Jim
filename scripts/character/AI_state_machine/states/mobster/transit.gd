class_name s
extends State

var current_patrol_point :Node2D = null

signal set_nav_target(pos : Vector2)
signal advance_navigation

var nav_target_reached = false
var setup_done = false
var host_position

func get_host_position():
	return ai_state_machine.get_perceptions().position

func get_host_nav_target_reached():
	return ai_state_machine.get_perceptions().nav_target_reached

func process(_delta: float) -> void:
	pass

func physics_process(_delta: float) -> void:
	if(ai_state_machine.get_perceptions().colliding_nodes.size() > 0):
		for node in ai_state_machine.get_perceptions().colliding_nodes:
			if(is_instance_valid(node) && node.is_in_group("spark")):
				ai_state_machine.transition_to("falling")
	else:
		nav_target_reached = get_host_nav_target_reached()
		if(!nav_target_reached):
			advance_navigation.emit()
		else:
			ai_state_machine.transition_to("look")

func enter(_msg := {}) -> void:
	if(current_patrol_point == null):
		var patrol_points = get_tree().get_nodes_in_group("patrol_point")
		current_patrol_point = patrol_points[0]
		for patrol_point in patrol_points:
			var distance_to_current_point = get_host_position().distance_to(current_patrol_point.position)
			var distance_to_other_point = get_host_position().distance_to(patrol_point.position)
			if(distance_to_other_point < distance_to_current_point):
				current_patrol_point = patrol_point
	else:
		if(current_patrol_point.has_next_point):
			current_patrol_point = current_patrol_point.next_point
	
	if(current_patrol_point != null):
		set_nav_target.emit(current_patrol_point.position)
		
	setup_done = true

func exit() -> void:
	pass
	
