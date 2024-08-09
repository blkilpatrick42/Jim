class_name NPC_Alert_Passive
extends State

signal behavior_directive(alert_passive : String)

var current_stage_mark : Vector2

func process(_delta: float) -> void:
	if(current_stage_mark == ai_state_machine.get_perceptions().current_stage_mark.global_position):
		behavior_directive.emit(NPC.alert_passive)
	else:
		ai_state_machine.transition_to(npc_states.transit)

func physics_process(_delta: float) -> void:
	pass

func enter(_msg := {}) -> void:
	current_stage_mark = ai_state_machine.get_perceptions().current_stage_mark.global_position

func exit() -> void:
	pass
