extends Control

@export var clock = 0
@export var hour_length_seconds = 30
var sound_player := AudioStreamPlayer.new()
var is_paused = false
var is_playing_song = false
var play_song_wait_sec = 1
var timer_world := Timer.new()
var timer_song := Timer.new()

#Called when the node enters the scene tree for the first time.
func _ready():
	add_child(sound_player)
	timer_world.one_shot = true
	timer_world.process_mode = Node.PROCESS_MODE_PAUSABLE
	timer_song.one_shot = true
	add_child(timer_world)
	add_child(timer_song)
	timer_world.start(hour_length_seconds)

func pause_game():
	if(!get_parent().get_tree().paused):
		sound_player.stream = load("res://audio/soundFX/opened.wav")
		sound_player.play()
		get_parent().get_tree().paused = true
		timer_song.start(play_song_wait_sec)
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
	if(!get_parent().get_tree().paused):
		#calculate clock
		if(timer_world.is_stopped()):
			timer_world.start(hour_length_seconds)
			if(clock != 23):
				clock = clock + 1
			else: if(clock == 23):
				clock = 0
	else: if (!is_playing_song && timer_song.is_stopped()):
		is_playing_song = true
		sound_player.stream = load("res://audio/music/Game is paused 2.wav")
		sound_player.play()

	
