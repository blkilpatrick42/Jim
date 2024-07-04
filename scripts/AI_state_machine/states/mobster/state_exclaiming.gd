class_name Exclaiming_State
extends State

signal stop()
signal exclaim_bubble()
signal stand(dir :String)
signal reduce_health()
signal drop_item()

var pause_time = 2
var timer : Timer

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
					elif(!ai_state_machine.get_perceptions().invincible &&
					 !node.is_in_group(ai_state_machine.get_perceptions().opposing_team)):
						ai_state_machine.transition_to(ai_state_machine.falling)
						return true
	return false

func handle_death():
	if(ai_state_machine.get_perceptions().hit_points <= 0):
		ai_state_machine.transition_to(ai_state_machine.falling)
		return true
	return false

func physics_process(_delta: float) -> void:
	if(handle_sparks()):
		return
	elif(handle_death()):
		return
	elif(timer.is_stopped()):
		ai_state_machine.transition_to(ai_state_machine.shooting)

func enter(_msg := {}) -> void:
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.start(pause_time)
	stop.emit()
	stand.emit("")
	exclaim_bubble.emit()

func exit() -> void:
	timer.queue_free()
	
