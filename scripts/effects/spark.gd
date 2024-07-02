extends Node

@onready var _animated_sprite = $AnimatedSprite2D

var source_obj : Node

func _ready():
	_animated_sprite.play("default")

func set_source_obj(obj : Node):
	source_obj = obj

func get_source_obj() -> Node:
	return source_obj

func _process(delta):
	if(_animated_sprite.frame == _animated_sprite.sprite_frames.get_frame_count("default")-1):
		queue_free()
