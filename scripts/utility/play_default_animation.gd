@tool

extends AnimatedSprite2D

@export var wait_offset : float = 0

var timer : Timer = Timer.new()

var random = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.one_shot = true
	add_child(timer)
	timer.start(random.randf_range(0,wait_offset))

func _process(delta : float) -> void:
	if(timer.is_stopped() && !is_playing()):
		var frames : SpriteFrames = sprite_frames
		var animation_name = "default"
		if(frames.has_animation(animation_name)):
			play(animation_name)
