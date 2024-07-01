class_name Knockedout_State
extends State

signal animate(animation : String)
signal reduce_health()
var timer := Timer.new() 
var knocked_out_time_secs = 10

func process(_delta: float) -> void:
	pass

func handle_sparks():
	if(ai_state_machine.get_perceptions().colliding_nodes.size() > 0):
		for node in ai_state_machine.get_perceptions().colliding_nodes:
				if(is_instance_valid(node) && node.is_in_group("spark")):
					if(node.is_in_group(ai_state_machine.get_perceptions().opposing_team) &&
					!ai_state_machine.get_perceptions().invincible):
						reduce_health.emit()
						return true
	return false

func physics_process(_delta: float) -> void:
	handle_sparks()
	if(timer.is_stopped()):
		ai_state_machine.transition_to(ai_state_machine.recovering)

func enter(_msg := {}) -> void:
	
	animate.emit(str("fallen_",ai_state_machine.perceptions.facing_dir))
	timer.one_shot = true
	add_child(timer)
	timer.start(knocked_out_time_secs)

func exit() -> void:
	pass
