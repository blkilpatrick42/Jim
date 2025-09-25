extends MarginContainer

@onready var resolution_label = $CenterContainer/VBoxContainer/resolution
@onready var integer_scaling_label = $CenterContainer/VBoxContainer/integer_scaling
@onready var full_screen_label = $CenterContainer/VBoxContainer/full_screen
@onready var light_quality_label = $CenterContainer/VBoxContainer/light_settings
@onready var back_label = $CenterContainer/VBoxContainer/back_label

#settings TODO: get these from a serializable class


var integer_scaling = true

var active_child_menu = null
var select_index = 0
var labels: Array[Node] = []
var menu_alpha = 1
var sound_player := AudioStreamPlayer2D.new()

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

func set_labels_alpha(alpha):
	for label in labels:
		var new_color = label.label_settings.font_color
		new_color.a = alpha
		label.modulate = new_color

func update_selection():
	var iterator = 0
	while(iterator < labels.size()):
		if(iterator == select_index):
			labels[iterator].modulate = Color(1,1,0,1)
		else:
			labels[iterator].modulate = Color(1,1,1,1)
		iterator+=1

func handle_selection():
	if(select_index == 0): #resolution
		if(SettingsVariables.resolution_index < SettingsVariables.supported_resolutions.size() -1):
			SettingsVariables.resolution_index += 1
		else:
			SettingsVariables.resolution_index = 0 
		get_viewport().content_scale_size = SettingsVariables.supported_resolutions[SettingsVariables.resolution_index]
	elif(select_index == 1): #integer scaling
		integer_scaling = !integer_scaling
		if(integer_scaling):
			get_viewport().content_scale_stretch = 1 #integer
		else:
			get_viewport().content_scale_stretch = 0 #fractional
	elif(select_index == 2): #full screen
		SettingsVariables.full_screen = !SettingsVariables.full_screen
		if(SettingsVariables.full_screen):
			get_viewport().mode = 4 #fullscreen
		else:
			get_viewport().mode = 2 #maximized 
	elif(select_index == 3): #resolution
		if(SettingsVariables.lighting_index < SettingsVariables.lighting_settings.size() -1):
			SettingsVariables.lighting_index += 1
		else:
			SettingsVariables.lighting_index = 0 
	elif(select_index == 4): #back
		queue_free()
		
func handle_input():
	if Input.is_action_just_pressed(direction.up):
		if(select_index > 0):
			reduce_index()
		else:
			block_index()
	if Input.is_action_just_pressed(direction.down):
		if(select_index < labels.size()-1):
			advance_index()
		else:
			block_index()
	if Input.is_action_just_pressed("interact"):
		handle_selection()

# Called when the node enters the scene tree for the first time.
func _ready():
	sound_player.bus = "Effects"
	add_child(sound_player)
	labels = [resolution_label, integer_scaling_label, full_screen_label, light_quality_label, back_label]
	set_labels_alpha(menu_alpha)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var resolution = SettingsVariables.supported_resolutions[SettingsVariables.resolution_index]
	resolution_label.text = str("RESOLUTION:\n",str(str(resolution.x,"x"),resolution.y))
	var int_scaling_str = "ON"
	if(!integer_scaling):
		int_scaling_str = "OFF"
	integer_scaling_label.text = str("INTEGER SCALING:\n",int_scaling_str)
	var full_screen_str = "ON"
	if(!SettingsVariables.full_screen):
		full_screen_str = "OFF"
	full_screen_label.text = str("FULL SCREEN:\n",full_screen_str)
	light_quality_label.text = str("LIGHTING QUALITY:\n",SettingsVariables.lighting_settings[SettingsVariables.lighting_index])
	menu_alpha = 1
	set_labels_alpha(menu_alpha)
	handle_input()
	update_selection()
		
		
