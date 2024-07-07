extends MarginContainer

@onready var start_label = $CenterContainer/VBoxContainer/start_game_label
@onready var settings_label = $CenterContainer/VBoxContainer/settings_label
@onready var quit_label = $CenterContainer/VBoxContainer/quit_label

var settings_menu = preload("res://entities/menu/settings menu/settings_menu.tscn")
var active_child_menu = null
var select_index = 0
var labels: Array[Node] = []
var menu_alpha = 0
var menu_alpha_step_size = 0.025
var alpha_step_time_secs = 0.05
var done_fading = false

var sound_player := AudioStreamPlayer2D.new()
var timer = Timer.new()

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
	if(select_index == 0): #start
		get_tree().change_scene_to_file("res://scenes/alpha_game_world_draft2.tscn") #TODO: game select menu
	elif(select_index == 1): #settings
		var child_settings_menu = settings_menu.instantiate()
		active_child_menu = child_settings_menu
		get_parent().add_child(child_settings_menu)
	elif(select_index == 2): #quit
		get_tree().quit()
		
func handle_input():
	if(done_fading):
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
	else: #skip the fading
		if (Input.is_action_just_pressed("start")||
		Input.is_action_just_pressed("pickup")):
			menu_alpha = 1
			set_labels_alpha(menu_alpha)
			return

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.one_shot = true
	add_child(timer)
	timer.start(alpha_step_time_secs)
	add_child(sound_player)
	labels = [start_label, settings_label, quit_label]
	set_labels_alpha(menu_alpha)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(active_child_menu == null):
		handle_input()
		#fade in menu
		if(!done_fading && timer.is_stopped()):
			menu_alpha += menu_alpha_step_size
			set_labels_alpha(menu_alpha)
			timer.start(alpha_step_time_secs)
			if(menu_alpha >= 1):
				done_fading = true
		else: if (done_fading): #once the menu is faded in
			menu_alpha = 1
			set_labels_alpha(menu_alpha)
			update_selection()
	else: #sub_menu is active
		menu_alpha = 0.0
		set_labels_alpha(menu_alpha)
		
		
