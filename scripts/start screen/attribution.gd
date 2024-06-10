@tool
extends Node2D

@onready var _motion_pic = $motion_pic
@onready var _logo = $logo

var hold_time = 1
var fade_step_secs = 0.025
var timer_fade := Timer.new()

var motion_pic_fade_alpha = 0.0
var logo_fade_alpha = 0.0

var fading_in = false
var holding = false
var fading_out = false
var done = true

var fade_step = 0.025

# Called when the node enters the scene tree for the first time.
func _ready():
	timer_fade.one_shot = true
	add_child(timer_fade)	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(fading_in && timer_fade.is_stopped()):
		if(motion_pic_fade_alpha < 1):
			motion_pic_fade_alpha += fade_step
			timer_fade.start(fade_step_secs)
		else:
			if(logo_fade_alpha < 1):
				logo_fade_alpha += fade_step
				timer_fade.start(fade_step_secs)
			else:
				fading_in = false
				holding=true
				timer_fade.start(hold_time)
	else: if (holding):
		if(timer_fade.is_stopped()):
			holding = false
			fading_out = true
	else: if(fading_out && timer_fade.is_stopped()):
		if(motion_pic_fade_alpha > 0):
			motion_pic_fade_alpha -= fade_step
			logo_fade_alpha -= fade_step
			timer_fade.start(fade_step_secs)
		else:
			done = true
	if(done):
		motion_pic_fade_alpha = 0.0
		logo_fade_alpha = 0.0
				
	_motion_pic.self_modulate.a = motion_pic_fade_alpha
	_logo.self_modulate.a = logo_fade_alpha

