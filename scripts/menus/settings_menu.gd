extends MarginContainer

@onready var audio_label = $CenterContainer/VBoxContainer/audio_label
@onready var video_label = $CenterContainer/VBoxContainer/video_label
@onready var back_label = $CenterContainer/VBoxContainer/back_label

var video_settings_menu = preload("res://menu/settings menu/video_settings.tscn")
var audio_settings_menu = preload("res://menu/settings menu/audio_settings.tscn")
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
	if(select_index == 0): #audio
		var child_settings_menu = audio_settings_menu.instantiate()
		active_child_menu = child_settings_menu
		get_parent().add_child(child_settings_menu)
	elif(select_index == 1): #settings
		var child_settings_menu = video_settings_menu.instantiate()
		active_child_menu = child_settings_menu
		get_parent().add_child(child_settings_menu)
	elif(select_index == 2): #back
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
	labels = [audio_label, video_label, back_label]
	set_labels_alpha(menu_alpha)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(active_child_menu == null):
		menu_alpha = 1
		set_labels_alpha(menu_alpha)
		handle_input()
		update_selection()
	else: #sub_menu is active
		menu_alpha = 0.0
		set_labels_alpha(menu_alpha)
		
		
