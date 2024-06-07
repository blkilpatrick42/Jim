class_name Look_State
extends State

signal turn_right
signal turn_left
signal stand(direction : String)

const turn_wait_time_secs = 2
const num_turns = 4
var current_num_turns = 0
var timer : Timer

func process(_delta: float) -> void:
	pass

func sparks_are_colliding():
	for node in ai_state_machine.get_perceptions().colliding_nodes:
			if(is_instance_valid(node) && node.is_in_group("spark")):
				return true
	return false

func physics_process(_delta: float):
	if(ai_state_machine.get_perceptions().colliding_nodes.size() > 0 &&
		sparks_are_colliding()):
			ai_state_machine.transition_to("falling")
	else:
		if(timer.is_stopped()):
			if(current_num_turns < num_turns):
				turn_right.emit()
				current_num_turns = current_num_turns + 1
				timer.start(turn_wait_time_secs)
				stand.emit("")
			else:
				ai_state_machine.transition_to("transit")

func enter(_msg := {}) -> void:
	timer = Timer.new()
	current_num_turns = 0
	timer.one_shot = true
	add_child(timer)
	timer.start(turn_wait_time_secs)
	stand.emit("")

func exit() -> void:
	timer.queue_free()
