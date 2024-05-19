extends Control

@export var clock = 0
@export var hour_length_seconds = 30
var time_checkpoint = 0
var sound_player := AudioStreamPlayer.new()
var is_paused = false
var is_playing_song = false
var play_song_wait_sec = 1

#Called when the node enters the scene tree for the first time.
func _ready():
	add_child(sound_player)
	time_checkpoint = Time.get_ticks_msec()

func pause_game():
	if(!get_parent().get_tree().paused):
		sound_player.stream = load("res://audio/soundFX/opened.wav")
		sound_player.play()
		get_parent().get_tree().paused = true
		time_checkpoint = Time.get_ticks_msec()
	else:
		is_playing_song = false
		sound_player.stream = load("res://audio/soundFX/closed.wav")
		sound_player.play()
		get_parent().get_tree().paused = false

func get_input():
	if Input.is_action_just_pressed("start"):
			pause_game()

#Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_input()
	var current_time = Time.get_ticks_msec()
	if(!get_parent().get_tree().paused):
		#calculate clock
		var diff_seconds = (current_time - time_checkpoint) / 1000
		if(diff_seconds >= hour_length_seconds):
			time_checkpoint = Time.get_ticks_msec()
			if(clock != 23):
				clock = clock + 1
			else: if(clock == 23):
				clock = 0
	else: if (!is_playing_song && ((current_time - time_checkpoint) / 1000) > play_song_wait_sec):
		is_playing_song = true
		sound_player.stream = load("res://audio/music/Game is paused 2.wav")
		sound_player.play()

	
