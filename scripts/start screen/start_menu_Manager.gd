extends Node
@onready var attribution = $attribution
@onready var start_game_label = $menu/base_canvas/start_game_label
@onready var settings_label = $menu/base_canvas/settings_label
@onready var quit_label = $menu/base_canvas/quit_label

var timer = Timer.new()
var base_canvas_alpha = 0.0
var fade_step_secs = 0.05
var fade_step = 0.025
var base_active = false
var base_select_index = 0 # 0 = start, 1 = settings, 2 = quit

var sound_player := AudioStreamPlayer2D.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	base_menu_fade_alpha(0.0)
	timer.one_shot = true
	add_child(timer)
	add_child(sound_player)
	pass # Replace with function body.

func base_menu_fade_alpha(alpha_value):
	start_game_label.modulate = Color(1,1,1,alpha_value)
	settings_label.modulate = Color(1,1,1,alpha_value)
	quit_label.modulate = Color(1,1,1,alpha_value)

func get_input():
	if(base_active):
		if Input.is_action_just_pressed(direction.up):
			if(base_select_index > 0):
				base_select_index -= 1
				sound_player.stream = load("res://audio/soundFX/voice/low_sine_voice/1.wav")
				sound_player.play()
			else:
				sound_player.stream = load("res://audio/soundFX/bigCollide.wav")
				sound_player.play()
		if Input.is_action_just_pressed(direction.down):
			if(base_select_index < 2):
				base_select_index += 1
				sound_player.stream = load("res://audio/soundFX/voice/low_sine_voice/1.wav")
				sound_player.play()
			else:
				sound_player.stream = load("res://audio/soundFX/bigCollide.wav")
				sound_player.play()
		if (Input.is_action_just_pressed("start")||
		Input.is_action_just_pressed("pickup")):
			if(base_select_index == 0): #START
				get_tree().change_scene_to_file("res://scenes/dev_base_3.tscn")
			if(base_select_index == 2): #QUIT
				get_tree().quit()
	else:
		if (Input.is_action_just_pressed("start")||
		Input.is_action_just_pressed("pickup")):
			attribution.done = true
			base_menu_fade_alpha(1)
			base_active = true
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_input()
	if(attribution.done):
		if(base_canvas_alpha < 1 && timer.is_stopped()):
			base_canvas_alpha += fade_step
			base_menu_fade_alpha(base_canvas_alpha)
			timer.start(fade_step_secs)
		else: if (base_canvas_alpha >= 1):
			base_active = true
	if(base_active):
		if(base_select_index == 0):
			start_game_label.modulate = Color(1,1,0,1)
			settings_label.modulate = Color(1,1,1,1)
			quit_label.modulate = Color(1,1,1,1)
		if(base_select_index == 1):
			start_game_label.modulate = Color(1,1,1,1)
			settings_label.modulate = Color(1,1,0,1)
			quit_label.modulate = Color(1,1,1,1)
		if(base_select_index == 2):
			start_game_label.modulate = Color(1,1,1,1)
			settings_label.modulate = Color(1,1,1,1)
			quit_label.modulate = Color(1,1,0,1)
		
