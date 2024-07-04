class_name Falling_State
extends State

signal one_shot_animate(animation : String)
signal stop_motion
signal turn_off_collision
signal play_sound(resource_name : String)
signal drop_item()

func process(_delta: float) -> void:
	pass

func physics_process(_delta: float) -> void:
	if(!ai_state_machine.get_perceptions().one_shot_animating):
		if(ai_state_machine.get_perceptions().hit_points > 0):
			play_sound.emit("res://audio/soundFX/smallCollide.wav")
			ai_state_machine.transition_to(ai_state_machine.knockedout)
		else:
			play_sound.emit("res://audio/soundFX/smallCollide.wav")
			ai_state_machine.transition_to(ai_state_machine.dead)

func enter(_msg := {}) -> void:
	var facing_dir = ai_state_machine.get_perceptions().facing_dir
	one_shot_animate.emit(str("fall_", facing_dir))
	stop_motion.emit()
	turn_off_collision.emit()
	drop_item.emit()

func exit() -> void:
	pass
