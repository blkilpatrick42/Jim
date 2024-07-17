extends Area2D

@export var label_name : String

signal activate_header(name : String)

func _on_body_entered(body : Node):
	if(body.is_in_group("player")):
		activate_header.emit(label_name)
