class_name Chasing_State
extends State

var current_patrol_point :Node2D = null

signal set_nav_target(pos: Vector2)
signal advance_navigation(speed: int)
signal question_bubble

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
				ai_state_machine.transition_to(ai_state_machine.falling)
	else:
		nav_target_reached = get_host_nav_target_reached()
		if(!nav_target_reached):
			advance_navigation.emit(400000)
		else:
			question_bubble.emit()
			ai_state_machine.transition_to(ai_state_machine.look)
			
		if(ai_state_machine.get_perceptions().has_line_of_sight_to_target):
				ai_state_machine.transition_to(ai_state_machine.strafing)

func enter(_msg := {}) -> void:
	var last_seen_pos = ai_state_machine.get_perceptions().target_pos
	set_nav_target.emit(last_seen_pos)

func exit() -> void:
	pass
	
