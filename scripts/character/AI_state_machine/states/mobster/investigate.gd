class_name Investigate_State
extends State

signal question_bubble()
signal set_target(node : Node)
signal face_pos(pos : Vector2)
signal stop()
signal stand(dir : String)

var timer : Timer
var investigate_time_secs = 3
var heard_pos : Vector2

func process(_delta: float) -> void:
	pass

func sparks_are_colliding():
	for node in ai_state_machine.get_perceptions().colliding_nodes:
			if(is_instance_valid(node) && node.is_in_group("spark")):
				return true
	return false

func physics_process(_delta: float) -> void:
	if(ai_state_machine.get_perceptions().colliding_nodes.size() > 0 &&
		sparks_are_colliding()):
			ai_state_machine.transition_to(ai_state_machine.falling)
	else:
		var player = get_tree().get_first_node_in_group("player")
		var nodes_in_vision = ai_state_machine.get_perceptions().nodes_in_vision
		if(nodes_in_vision.has(player)):
			set_target.emit(player)
			if(ai_state_machine.get_perceptions().has_line_of_sight_to_target):
				ai_state_machine.transition_to(ai_state_machine.exclaiming)
			return
		if(timer.is_stopped()):
			ai_state_machine.transition_to(ai_state_machine.look)

func enter(_msg := {}) -> void:
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.start(investigate_time_secs)
	question_bubble.emit()
	heard_pos = ai_state_machine.get_perceptions().nodes_in_hearing[0].global_position
	stop.emit()
	face_pos.emit(heard_pos)
	stand.emit("")

func exit() -> void:
	timer.queue_free()
