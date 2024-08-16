extends MarginContainer

@onready var master_label = $CenterContainer/VBoxContainer/master_volume
@onready var music_label = $CenterContainer/VBoxContainer/music_volume
@onready var effects_label = $CenterContainer/VBoxContainer/effects_volume
@onready var back_label = $CenterContainer/VBoxContainer/back_label

var active_child_menu = null
var select_index = 0
var labels: Array[Node] = []
var menu_alpha = 1
var sound_player := AudioStreamPlayer2D.new()
var db_step = 2
var bottom_volume = 80
var bus_headroom = 6
var scroll_timer : Timer = Timer.new()
var scroll_step_time = 0.05
var play_bump = true

# Called when the node enters the scene tree for the first time.
func _ready():
	sound_player.bus = "Effects"
	add_child(sound_player)
	labels = [master_label, music_label, effects_label, back_label]
	set_labels_alpha(menu_alpha)
	scroll_timer.one_shot = true
	add_child(scroll_timer)

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
	if(select_index == 0): #master volume
		pass
	elif(select_index == 1): #music volume
		pass
	elif(select_index == 2): #effects volume
		pass
	elif(select_index == 3): #back
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
	if(select_index != 3):
		if Input.is_action_pressed(direction.left):
			lower_bus_volume(select_index)
		elif Input.is_action_pressed(direction.right):
			raise_bus_volume(select_index)
		else:
			play_bump = true
	if Input.is_action_just_pressed("interact"):
		handle_selection()

func raise_bus_volume(bus : int):
	if(scroll_timer.is_stopped()):
		var volume : float = AudioServer.get_bus_volume_db(bus)
		if(bus == 0 && volume == 0 || #master is at full output
		   bus != 0 && volume == -bus_headroom): #other buses have headroom
			sound_player.stream = load("res://audio/soundFX/bigCollide.wav")
			if(play_bump):
				sound_player.play()
				play_bump = false
		else:
			AudioServer.set_bus_volume_db(bus, volume + db_step)
			sound_player.stream = load("res://audio/soundFX/voice/low_sine_voice/1.wav")
			sound_player.play()
		scroll_timer.start(scroll_step_time)

func lower_bus_volume(bus : int):
	if(scroll_timer.is_stopped()):
		var volume : float = AudioServer.get_bus_volume_db(bus)
		if(volume == -bottom_volume):
			sound_player.stream = load("res://audio/soundFX/bigCollide.wav")
			if(play_bump):
				sound_player.play()
				play_bump = false
		else:
			AudioServer.set_bus_volume_db(bus, volume - db_step)
			sound_player.stream = load("res://audio/soundFX/voice/low_sine_voice/1.wav")
			sound_player.play()
		scroll_timer.start(scroll_step_time)

func get_volume_bar(volume : float, is_master : bool = false):
	var num_ticks = 40
	var adjusted_bottom_volume = bottom_volume
	if(!is_master):
		volume = volume + bus_headroom
		adjusted_bottom_volume = adjusted_bottom_volume - bus_headroom
	var bar_ticks : int = abs(num_ticks * (((adjusted_bottom_volume+1)+volume)/adjusted_bottom_volume))
	var bar = "["
	var iterator = 1
	while (iterator <= num_ticks):
		if(iterator <= bar_ticks):
			bar = str(bar,"|")
		else:
			bar = str(bar,":")
		iterator = iterator + 1
	bar = str(bar,"]")
	return bar
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var master_volume = "MASTER VOLUME:"
	var master_volume_level : float = AudioServer.get_bus_volume_db(0)
	if(select_index == 0):
		var master_label_text = str(master_volume,"\n<",get_volume_bar(master_volume_level, true),">")
		master_label.text = master_label_text
	else:
		var master_label_text = str(master_volume,"\n",get_volume_bar(master_volume_level, true))
		master_label.text = master_label_text
	var music_volume = "MUSIC VOLUME:"
	var music_volume_level : float = AudioServer.get_bus_volume_db(1)
	if(select_index == 1):
		var music_label_text = str(music_volume,"\n<",get_volume_bar(music_volume_level),">")
		music_label.text = music_label_text
	else:
		var music_label_text = str(music_volume,"\n",get_volume_bar(music_volume_level))
		music_label.text = music_label_text
	var effects_volume = "EFFECTS VOLUME:"
	var effects_volume_level : float = AudioServer.get_bus_volume_db(2)
	if(select_index == 2):
		var effects_label_text = str(effects_volume,"\n<",get_volume_bar(effects_volume_level),">")
		effects_label.text = effects_label_text
	else:
		var effects_label_text = str(effects_volume,"\n",get_volume_bar(effects_volume_level))
		effects_label.text = effects_label_text
	menu_alpha = 1
	set_labels_alpha(menu_alpha)
	handle_input()
	update_selection()
		
		
