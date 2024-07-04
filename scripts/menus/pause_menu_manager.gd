extends MarginContainer

#@onready var resume_label = $CenterContainer/VBoxContainer/resume_game_label
@onready var settings_label = $CenterContainer/VBoxContainer/settings_label
@onready var quit_label = $CenterContainer/VBoxContainer/quit_label

var settings_menu = preload("res://entities/menu/settings menu/settings_menu.tscn")
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
	if(select_index == 0): #settings
		var child_settings_menu = settings_menu.instantiate()
		active_child_menu = child_settings_menu
		get_parent().add_child(child_settings_menu)
	elif(select_index == 1): #quit to start menu
		get_parent().get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/start_menu.tscn") #TODO: ask if they are sure
		
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
	if Input.is_action_just_pressed("pickup"):
		handle_selection()

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(sound_player)
	labels = [settings_label, quit_label]
	set_labels_alpha(menu_alpha)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(active_child_menu == null):
		handle_input()
		menu_alpha = 1
		set_labels_alpha(menu_alpha)
		update_selection()
	else: #sub_menu is active
		menu_alpha = 0.0
		set_labels_alpha(menu_alpha)
		
		
