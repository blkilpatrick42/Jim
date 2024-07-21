extends Control

var pause_menu = preload("res://menu/pause menu/pause_menu_manager.tscn")

@export var clock = 0.0
@export var hour_length_seconds = 30.0
var sound_player := AudioStreamPlayer.new()
var is_menu_paused = false
var is_game_over = false
var is_playing_song = false
var play_song_wait_sec = 1
var timer_world := Timer.new()
var timer_song := Timer.new()
var timer_restart := Timer.new()
var ambient_dark = null

var day_of_the_week = 0
var days_in_week = [
	"Sunday",
	"Monday",
	"Tuesday",
	"Wednesday",
	"Thursday",
	"Friday",
	"Saturday"
]

var restart_wait_sec = 30

var player_ref = null

var pause_menu_ref = null

#Called when the node enters the scene tree for the first time.
func _ready():
	sound_player.bus = "Music"
	add_child(sound_player)
	timer_world.one_shot = true
	timer_world.process_mode = Node.PROCESS_MODE_PAUSABLE
	timer_song.one_shot = true
	timer_restart.one_shot = true
	add_child(timer_world)
	add_child(timer_song)
	add_child(timer_restart)
	timer_world.start(hour_length_seconds)
	ambient_dark = get_tree().get_nodes_in_group("ambient_dark")[0]
	player_ref = get_parent().get_tree().get_nodes_in_group("player")[0]

func get_hour_length_seconds():
	return hour_length_seconds

func get_time_as_ratio_of_full_day() -> float:
	var ratio = 0.0
	ratio = (clock+1.0)/24.0
	ratio += ((hour_length_seconds - timer_world.time_left)/hour_length_seconds) * (1.0/24.0)
	return ratio

func toggle_pause_parent_tree():
	if(!get_parent().get_tree().paused):
		get_parent().get_tree().paused = true
	else:
		get_parent().get_tree().paused = false

func toggle_menu_pause():
	if(!is_game_over):
		if(!is_menu_paused):
			if(!player_ref.control_frozen):
				pause_menu_ref = pause_menu.instantiate()
				player_ref.add_child(pause_menu_ref)
				is_menu_paused = true
				sound_player.stream = load("res://audio/soundFX/opened.wav")
				sound_player.play()
				toggle_pause_parent_tree()
				timer_song.start(play_song_wait_sec)
		else:
			pause_menu_ref.queue_free()
			is_menu_paused = false
			is_playing_song = false
			sound_player.stream = load("res://audio/soundFX/closed.wav")
			sound_player.play()
			toggle_pause_parent_tree()

func game_over():
	toggle_pause_parent_tree()
	ambient_dark.fade_to_black()

func get_informal_time_string() -> String:
	var informal_string = ""
	if(clock > 12):
		informal_string = str(clock - 12, "PM")
	else:
		informal_string = str (clock, "AM")
	return informal_string

func get_input():
	if Input.is_action_just_pressed("start"):
		if(!is_game_over):
			toggle_menu_pause()
		else: if(is_game_over):
			toggle_pause_parent_tree()
			get_tree().reload_current_scene()

#Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_input()
	if(!is_menu_paused):
		#calculate clock
		if(timer_world.is_stopped()):
			timer_world.start(hour_length_seconds)
			if(clock != 23):
				clock = clock + 1
			else: if(clock == 23):
				clock = 0
	else: if (is_menu_paused && !is_playing_song && timer_song.is_stopped()):
		is_playing_song = true
		sound_player.stream = load("res://audio/music/Game is paused 2.wav")
		sound_player.play()
	
	if(player_ref.dead && !is_game_over):
		is_game_over = true
		game_over()
		
