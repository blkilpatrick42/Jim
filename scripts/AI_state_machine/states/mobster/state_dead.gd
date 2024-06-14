class_name Dead_State
extends State

signal queue_free()
signal disable_collision()
signal animate(animation : String)
signal die_skull()
var timer := Timer.new() 
var disappear_time_secs = 10

func process(_delta: float) -> void:
	pass

func physics_process(_delta: float) -> void:
	if(timer.is_stopped()):
		queue_free.emit()

func enter(_msg := {}) -> void:
	animate.emit(str("fallen_",ai_state_machine.perceptions.facing_dir))
	disable_collision.emit()
	die_skull.emit()
	timer.one_shot = true
	add_child(timer)
	timer.start(disappear_time_secs)

func exit() -> void:
	pass
