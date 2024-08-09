class_name NPC_Idle_State
extends State

signal stand(direction : String)

func process(_delta: float) -> void:
	pass

func physics_process(_delta: float) -> void:
	ai_state_machine.transition_to(npc_states.transit)

func enter(_msg := {}) -> void:
	pass

func exit() -> void:
	pass
