extends Node2D

@onready var _character_base = $character_base
@onready var _tough_luck = $tough_luck
var sound_player := AudioStreamPlayer2D.new()

var facing_direction = "right"
var running_animation = false
var frame_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(sound_player)

func set_facing_direction(dir):
	facing_direction = dir

func start_dyin(dir):
	if(!running_animation):
		sound_player.stream = load("res://audio/music/dyin_theme.wav")
		sound_player.play()
		set_facing_direction(dir)
		var animation_name = str("die_",facing_direction)
		frame_count = _character_base.get_base_animation_framecount(animation_name)
		running_animation = true
		_character_base.play_animation(animation_name)
		_character_base.set_speed_scales(1)

func _process(delta):
	if(running_animation):
		if(_character_base.get_base_current_frame() == frame_count-1):
			var animation_name = str("fallen_",facing_direction)
			_character_base.play_animation(animation_name)
			_tough_luck.visible = true
