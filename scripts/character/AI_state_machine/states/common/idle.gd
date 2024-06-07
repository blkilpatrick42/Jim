class_name Idle_State
extends State

signal stand(direction : String)

func process(_delta: float) -> void:
	pass

func physics_process(_delta: float) -> void:
	stand.emit("right")

func enter(_msg := {}) -> void:
	pass

func exit() -> void:
	pass
