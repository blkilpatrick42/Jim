extends Node

@onready var _animated_sprite = $AnimatedSprite2D

var timer = 500
var timer_chkpt = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	_animated_sprite.play("default")
	timer_chkpt = Time.get_ticks_msec()

func _process(delta):
	if(((Time.get_ticks_msec() - timer_chkpt)) >= timer):
		queue_free()
