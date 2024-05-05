extends Node

@onready var _animated_sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	_animated_sprite.play("default")

func _process(delta):
	if(_animated_sprite.frame == _animated_sprite.sprite_frames.get_frame_count("default")-1):
		queue_free()
