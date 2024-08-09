class_name NPC_Transit_State
extends State

signal set_nav_target(pos : Vector2)
signal advance_navigation(speed : int)

var nav_target_reached = false
var host_position
var current_stage_mark : Node = null

const distance_to_break_current_point = 128

func get_host_position():
	return ai_state_machine.get_perceptions().position

func get_host_nav_target_reached():
	return ai_state_machine.get_perceptions().nav_target_reached

func process(_delta: float) -> void:
	pass

func get_stage_mark():
	current_stage_mark = ai_state_machine.get_perceptions().current_stage_mark
	if(current_stage_mark != null):
		set_nav_target.emit(current_stage_mark.position)

func physics_process(_delta: float) -> void:
	if(current_stage_mark != null):
		nav_target_reached = get_host_nav_target_reached()
		if(!nav_target_reached):
			advance_navigation.emit(125000)
		else:
			var stage_mark_state : String = current_stage_mark.get_state()
			ai_state_machine.transition_to(stage_mark_state)
	else:
		get_stage_mark()

func enter(_msg := {}) -> void:
	pass

func exit() -> void:
	pass
	
