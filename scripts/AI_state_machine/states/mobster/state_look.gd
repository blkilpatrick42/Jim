class_name Look_State
extends State

signal turn_right
signal turn_left
signal stand(direction : String)
signal set_target(target : Node)
signal reduce_health()

const turn_wait_time_secs = 2
const num_turns = 4
var current_num_turns = 0
var timer : Timer

func process(_delta: float) -> void:
	pass

func handle_sparks():
	if(ai_state_machine.get_perceptions().colliding_nodes.size() > 0):
		for node in ai_state_machine.get_perceptions().colliding_nodes:
				if(is_instance_valid(node) && node.is_in_group("spark")):
					if(node.is_in_group(ai_state_machine.get_perceptions().opposing_team)):
						reduce_health.emit()
						return true
					elif(!ai_state_machine.get_perceptions().invincible):
						ai_state_machine.transition_to(ai_state_machine.falling)
						return true
	return false

func handle_death():
	if(ai_state_machine.get_perceptions().hit_points <= 0 &&
					!ai_state_machine.get_perceptions().invincible):
		ai_state_machine.transition_to(ai_state_machine.falling)
		return true
	return false

func physics_process(_delta: float):
	#check knockout
	if(handle_sparks()):
		return
	elif(handle_death()):
		return
	else:
		#check for targets
		var player = get_tree().get_first_node_in_group("player")
		var nodes_in_vision = ai_state_machine.get_perceptions().nodes_in_vision
		var nodes_in_hearing = ai_state_machine.get_perceptions().nodes_in_hearing
		for node in nodes_in_vision:
			if(node != null && node.is_in_group(ai_state_machine.get_perceptions().opposing_team) &&
			node.is_in_group("mobster")):
				set_target.emit(node)
				if(ai_state_machine.get_perceptions().has_line_of_sight_to_target):
					ai_state_machine.transition_to(ai_state_machine.exclaiming)
					return
		if(nodes_in_vision.has(player)):
			set_target.emit(player)
			if(ai_state_machine.get_perceptions().has_line_of_sight_to_target):
				ai_state_machine.transition_to(ai_state_machine.exclaiming)
		elif(nodes_in_hearing.size() > 0):
			ai_state_machine.transition_to(ai_state_machine.investigate)
		#look state code
		elif(timer.is_stopped()):
			if(current_num_turns < num_turns):
				turn_right.emit()
				current_num_turns = current_num_turns + 1
				timer.start(turn_wait_time_secs)
				stand.emit("")
			else:
				ai_state_machine.transition_to(ai_state_machine.transit)

func enter(_msg := {}) -> void:
	timer = Timer.new()
	current_num_turns = 0
	timer.one_shot = true
	add_child(timer)
	timer.start(turn_wait_time_secs)
	stand.emit("")

func exit() -> void:
	timer.queue_free()
