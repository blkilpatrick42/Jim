extends Node
#BASE
var timer = Timer.new()
var base_canvas_alpha = 0.0
var fade_step_secs = 0.05
var fade_step = 0.025
var base_active = false
var base_max_index = 3
@onready var attribution = $attribution
@onready var start_game_label = $menu/base_canvas/start_game_label
@onready var settings_label = $menu/base_canvas/settings_label
@onready var quit_label = $menu/base_canvas/quit_label

#SETTINGS
var settings_canvas_alpha = 0.0
var settings_active = false
var video_settings_active = false
var settings_max_index = 3
@onready var settings_back_label = $menu/settings_canvas/settings_back_label
#AUDIO
@onready var audio_label = $menu/settings_canvas/audio_label
#VIDEO
var video_max_index = 4
@onready var video_label = $menu/settings_canvas/video_label
@onready var resolution_label = $menu/settings_canvas/video_canvas/resolution
var supported_resolutions = [Vector2(600,360),Vector2(632,320), Vector2(640,360)]
var resolution_index = 0
#var resolution = supported_resolutions[0]
@onready var integer_scaling_label = $menu/settings_canvas/video_canvas/integer_scaling
var integer_scaling = true
@onready var full_screen_label = $menu/settings_canvas/video_canvas/full_screen
var full_screen = false
@onready var video_back_label = $menu/settings_canvas/video_canvas/video_back_label

var select_index = 0
var current_max_index = 0

var sound_player := AudioStreamPlayer2D.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	base_menu_fade_alpha(0.0)
	settings_menu_fade_alpha(0.0)
	video_settings_fade_alpha(0.0)
	timer.one_shot = true
	add_child(timer)
	add_child(sound_player)

func base_menu_fade_alpha(alpha_value):
	start_game_label.modulate = Color(1,1,1,alpha_value)
	settings_label.modulate = Color(1,1,1,alpha_value)
	quit_label.modulate = Color(1,1,1,alpha_value)
	
func settings_menu_fade_alpha(alpha_value):
	audio_label.modulate = Color(1,1,1,alpha_value)
	video_label.modulate = Color(1,1,1,alpha_value)
	settings_back_label.modulate = Color(1,1,1,alpha_value)

func video_settings_fade_alpha(alpha_value):
	resolution_label.modulate = Color(1,1,1,alpha_value)
	integer_scaling_label.modulate = Color(1,1,1,alpha_value)
	full_screen_label.modulate = Color(1,1,1,alpha_value)
	video_back_label.modulate = Color(1,1,1,alpha_value)

func advance_index():
	select_index += 1
	sound_player.stream = load("res://audio/soundFX/voice/low_sine_voice/1.wav")
	sound_player.play()
	
func reduce_index():
	select_index -= 1
	sound_player.stream = load("res://audio/soundFX/voice/low_sine_voice/1.wav")
	sound_player.play()

func block_index():
	sound_player.stream = load("res://audio/soundFX/bigCollide.wav")
	sound_player.play()

#TODO: come back and raze this forest of if statements
#I am serious this is disgusting next time you touch this file
#actually code something please
func get_input():
	if(base_active || settings_active):
		if Input.is_action_just_pressed(direction.up):
			if(select_index > 0):
				reduce_index()
			else:
				block_index()
		if Input.is_action_just_pressed(direction.down):
			if(select_index < current_max_index-1):
				advance_index()
			else:
				block_index()
	else: #skip the BS
		if (Input.is_action_just_pressed("start")||
		Input.is_action_just_pressed("pickup")):
			attribution.done = true
			base_menu_fade_alpha(1)
			base_active = true
			return

	if(base_active):
		current_max_index = base_max_index
		if (Input.is_action_just_pressed("pickup")):
			if(select_index == 0): #START
				get_tree().change_scene_to_file("res://scenes/dev_base_3.tscn")
			if(select_index == 1): #SETTINGS
				base_menu_fade_alpha(0)
				settings_menu_fade_alpha(1)
				select_index = 0
				settings_active = true
				base_active = false
			if(select_index == 2): #QUIT
				get_tree().quit()
	if(settings_active):
		if(video_settings_active):
				current_max_index = video_max_index
				if (Input.is_action_just_pressed("pickup")):
					if(select_index == 0): #RESOLUTION
							if(resolution_index < supported_resolutions.size() -1):
								resolution_index += 1
							else:
								resolution_index = 0 
							get_viewport().content_scale_size = supported_resolutions[resolution_index]
					if(select_index == 1): #INTEGER SCALING
						integer_scaling = !integer_scaling
						if(integer_scaling):
							get_viewport().content_scale_stretch = 1 #integer
						else:
							get_viewport().content_scale_stretch = 0 #fractional
					if(select_index == 2): #FULL SCREEN
						full_screen = !full_screen
						if(full_screen):
							get_viewport().mode = 3 #fullscreen
						else:
							get_viewport().mode = 2 #maximized
					if(select_index == 3): #BACK
						base_menu_fade_alpha(0)
						settings_menu_fade_alpha(1)
						video_settings_fade_alpha(0)
						select_index = 0
						settings_active = true
						video_settings_active = false
		else:
			current_max_index = settings_max_index
			if (Input.is_action_just_pressed("pickup")):
				if(select_index == 0): #AUDIO
					pass 
				if(select_index == 1): #VIDEO
					base_menu_fade_alpha(0)
					settings_menu_fade_alpha(0)
					video_settings_fade_alpha(1)
					select_index = 0
					settings_active = true
					video_settings_active = true
				if(select_index == 2): #BACK
					base_menu_fade_alpha(1)
					settings_menu_fade_alpha(0)
					select_index = 0
					settings_active = false
					base_active = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_input()
	if(attribution.done && !settings_active):
		if(!base_active && base_canvas_alpha < 1 && timer.is_stopped()):
			base_canvas_alpha += fade_step
			base_menu_fade_alpha(base_canvas_alpha)
			timer.start(fade_step_secs)
		else: if (base_canvas_alpha >= 1):
			base_active = true

	if(base_active):
		if(select_index == 0):
			start_game_label.modulate = Color(1,1,0,1)
			settings_label.modulate = Color(1,1,1,1)
			quit_label.modulate = Color(1,1,1,1)
		if(select_index == 1):
			start_game_label.modulate = Color(1,1,1,1)
			settings_label.modulate = Color(1,1,0,1)
			quit_label.modulate = Color(1,1,1,1)
		if(select_index == 2):
			start_game_label.modulate = Color(1,1,1,1)
			settings_label.modulate = Color(1,1,1,1)
			quit_label.modulate = Color(1,1,0,1)
			
	if(settings_active):
		if(video_settings_active):
			var resolution = supported_resolutions[resolution_index]
			resolution_label.text = str("RESOLUTION:\n",str(str(resolution.x,"x"),resolution.y))
			var int_scaling_str = "ON"
			if(!integer_scaling):
				int_scaling_str = "OFF"
			integer_scaling_label.text = str("INTEGER SCALING:\n",int_scaling_str)
			var full_screen_str = "ON"
			if(!full_screen):
				full_screen_str = "OFF"
			full_screen_label.text = str("FULL SCREEN:\n",full_screen_str)
			if(select_index == 0):
				resolution_label.modulate = Color(1,1,0,1)
				integer_scaling_label.modulate = Color(1,1,1,1)
				full_screen_label.modulate = Color(1,1,1,1)
				video_back_label.modulate = Color(1,1,1,1)
			if(select_index == 1):
				resolution_label.modulate = Color(1,1,1,1)
				integer_scaling_label.modulate = Color(1,1,0,1)
				full_screen_label.modulate = Color(1,1,1,1)
				video_back_label.modulate = Color(1,1,1,1)
			if(select_index == 2):
				resolution_label.modulate = Color(1,1,1,1)
				integer_scaling_label.modulate = Color(1,1,1,1)
				full_screen_label.modulate = Color(1,1,0,1)
				video_back_label.modulate = Color(1,1,1,1)
			if(select_index == 3):
				resolution_label.modulate = Color(1,1,1,1)
				integer_scaling_label.modulate = Color(1,1,1,1)
				full_screen_label.modulate = Color(1,1,1,1)
				video_back_label.modulate = Color(1,1,0,1)
		else:
			if(select_index == 0):
				audio_label.modulate = Color(1,1,0,1)
				video_label.modulate = Color(1,1,1,1)
				settings_back_label.modulate = Color(1,1,1,1)
			if(select_index == 1):
				audio_label.modulate = Color(1,1,1,1)
				video_label.modulate = Color(1,1,0,1)
				settings_back_label.modulate = Color(1,1,1,1)
			if(select_index == 2):
				audio_label.modulate = Color(1,1,1,1)
				video_label.modulate = Color(1,1,1,1)
				settings_back_label.modulate = Color(1,1,0,1)
		
