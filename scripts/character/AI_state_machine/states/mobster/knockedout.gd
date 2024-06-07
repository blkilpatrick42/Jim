class_name Knockedout_State
extends State

signal animate(animation : String)
var timer := Timer.new() 
var knocked_out_time_secs = 10

func process(_delta: float) -> void:
	pass

func physics_process(_delta: float) -> void:
	if(timer.is_stopped()):
		ai_state_machine.transition_to("recovering")

func enter(_msg := {}) -> void:
	animate.emit(str("fallen_",ai_state_machine.perceptions.facing_dir))
	timer.one_shot = true
	add_child(timer)
	timer.start(knocked_out_time_secs)

func exit() -> void:
	pass
