class_name Falling_State
extends State

signal one_shot_animate(animation : String)
signal stop_motion
signal turn_off_head_collider

func process(_delta: float) -> void:
	pass

func physics_process(_delta: float) -> void:
	if(!ai_state_machine.get_perceptions().one_shot_animating):
		ai_state_machine.transition_to("knockedout")

func enter(_msg := {}) -> void:
	var facing_dir = ai_state_machine.get_perceptions().facing_dir
	one_shot_animate.emit(str("fall_", facing_dir))
	stop_motion.emit()
	turn_off_head_collider.emit()

func exit() -> void:
	pass