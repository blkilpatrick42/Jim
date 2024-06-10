class_name Strafing_State
extends State

var current_patrol_point :Node2D = null

signal set_strafe_point()
signal advance_navigation
signal set_target(target : Node)

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
			advance_navigation.emit(250000)
		else:
			ai_state_machine.transition_to(ai_state_machine.shooting)

func enter(_msg := {}) -> void:
	set_strafe_point.emit()

func exit() -> void:
	pass
	
