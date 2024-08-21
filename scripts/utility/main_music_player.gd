extends AudioStreamPlayer

var current_stream : String = ""

var current_volume = 0
var zero_volume = -60

var timer : Timer = Timer.new()
var fade_step = 3
var fade_step_time = 0.05
#var start_new_stream_wait_time = 1

var changing_streams = false
#var ready_play_new_stream = false

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.one_shot = true
	add_child(timer)
	bus = "Music"

func change_stream(new_stream: String):
	#if(current_stream != ""):
	changing_streams = true
	current_stream = new_stream
	timer.start(fade_step_time)
	#else:
		#current_volume = 0
		#changing_streams = false
		#current_stream = new_stream
		#stream = load(new_stream)
		#play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(changing_streams && timer.is_stopped()):
		if(current_volume > zero_volume):
			current_volume = current_volume - fade_step
			volume_db = current_volume
			timer.start(fade_step_time)
		elif(current_volume <= zero_volume):
			stop()
			changing_streams = false
			if(current_stream != ""):
				current_volume = 0
				volume_db = current_volume
				stream = load(current_stream)
				play()
				
			
			
