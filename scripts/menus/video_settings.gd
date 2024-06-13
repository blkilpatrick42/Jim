extends MarginContainer

@onready var resolution_label = $CenterContainer/VBoxContainer/resolution
@onready var integer_scaling_label = $CenterContainer/VBoxContainer/integer_scaling
@onready var full_screen_label = $CenterContainer/VBoxContainer/full_screen
@onready var back_label = $CenterContainer/VBoxContainer/back_label

#settings TODO: get these from a serializable class
var supported_resolutions = [Vector2(632,320),Vector2(600,360),Vector2(640,360)]
var resolution_index = 0
var full_screen = false
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
		if(resolution_index < supported_resolutions.size() -1):
			resolution_index += 1
		else:
			resolution_index = 0 
		get_viewport().content_scale_size = supported_resolutions[resolution_index]
	elif(select_index == 1): #integer scaling
		integer_scaling = !integer_scaling
		if(integer_scaling):
			get_viewport().content_scale_stretch = 1 #integer
		else:
			get_viewport().content_scale_stretch = 0 #fractional
	elif(select_index == 2): #full screen
		full_screen = !full_screen
		if(full_screen):
			get_viewport().mode = 3 #fullscreen
		else:
			get_viewport().mode = 2 #maximized 
	elif(select_index == 3): #back
		queue_free()
		
func handle_input():
	if Input.is_action_just_pressed(direction.up):
		if(select_index > 0):
			reduce_index()
		else:
			block_index()
	if Input.is_action_just_pressed(direction.down):
		if(select_index < labels.size()):
			advance_index()
		else:
			block_index()
	if Input.is_action_just_pressed("pickup"):
		handle_selection()

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(sound_player)
	labels = [resolution_label, integer_scaling_label, full_screen_label, back_label]
	set_labels_alpha(menu_alpha)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
	menu_alpha = 1
	set_labels_alpha(menu_alpha)
	handle_input()
	update_selection()
		
		
