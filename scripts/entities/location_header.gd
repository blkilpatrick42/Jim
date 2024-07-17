extends Control

var label_settings = preload("res://dialog/bubble_settings.tres")
@onready var _label = $Label
@onready var _sprite = $sprite

var timer : Timer = Timer.new()

var fade_alpha = 0 
var fade_step_secs = 0.05
var fade_step_alpha = 0.1
var fade_long_step_secs = 1

var fading_in = false
var fading_out = false

func _ready():
	set_fade_alpha(fade_alpha)
	timer.one_shot = true
	add_child(timer)

func set_label(text : String):
	_label.text = text

func activate_header(text: String):
	set_label(text)
	fade_in()

func fade_in():
	fading_in = true
	timer.start(fade_step_secs)

func set_fade_alpha(alpha : float):
	_sprite.modulate = Color(1,1,1,fade_alpha)
	_label.label_settings.font_color = Color(0,0,0,fade_alpha)

func _process(delta):
	if(timer.is_stopped()):
		if(fading_in):
			if(fade_alpha < 1):
				fade_alpha += fade_step_alpha
				set_fade_alpha(fade_alpha)
				timer.start(fade_step_secs)
			elif(fade_alpha >= 1):
				fading_in = false
				fading_out = true
				timer.start(fade_long_step_secs)
		elif(fading_out):
			if(fade_alpha > 0):
				fade_alpha -= fade_step_alpha
				set_fade_alpha(fade_alpha)
				timer.start(fade_step_secs)
			elif(fade_alpha <= 0):
				fade_alpha = 0
				fading_out = false
