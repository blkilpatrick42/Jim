extends Node

@onready var _animated_sprite = $AnimatedSprite2D

@export var timer_time_secs = 30

var timer = Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.one_shot = true
	add_child(timer)
	timer.start(timer_time_secs)
	_animated_sprite.play("default")

func _process(delta):
	if(_animated_sprite.frame == _animated_sprite.sprite_frames.get_frame_count("default")-1):
		_animated_sprite.play("done")
	if(timer.is_stopped()):
		queue_free()
