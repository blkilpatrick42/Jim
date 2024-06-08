class_name Exclaiming_State
extends State

signal stop()
signal exclaim_bubble()
signal stand(dir :String)

var pause_time = 2
var timer : Timer

func process(_delta: float) -> void:
	pass

func physics_process(_delta: float) -> void:
	if(timer.is_stopped()):
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
	
