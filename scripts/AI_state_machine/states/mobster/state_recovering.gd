class_name Recovering_State
extends State

signal one_shot_animate(animation : String)
signal turn_on_head_collider

func process(_delta: float) -> void:
	pass

func physics_process(_delta: float) -> void:
	if(!ai_state_machine.get_perceptions().one_shot_animating):
		turn_on_head_collider.emit()
		ai_state_machine.transition_to(mobster_states.look)

func enter(_msg := {}) -> void:
	one_shot_animate.emit(str("recover_",ai_state_machine.get_perceptions().facing_dir))

func exit() -> void:
	pass
