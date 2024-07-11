class_name Dead_State
extends State

signal queue_free()
signal disable_collision()
signal animate(animation : String)
signal die_skull()
signal blood()
signal adjust_offset(adjustment : Vector2)
var timer := Timer.new() 
var disappear_time_secs = 60
var sprite_offset_amt = 16

func process(_delta: float) -> void:
	pass

func physics_process(_delta: float) -> void:
	if(timer.is_stopped()):
		queue_free.emit()

func enter(_msg := {}) -> void:
	animate.emit(str("fallen_",ai_state_machine.perceptions.facing_dir))
	disable_collision.emit()
	adjust_offset.emit(Vector2(0,sprite_offset_amt))
	die_skull.emit()
	blood.emit()
	timer.one_shot = true
	add_child(timer)
	timer.start(disappear_time_secs)

func exit() -> void:
	pass
