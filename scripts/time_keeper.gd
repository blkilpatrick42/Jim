extends Control

@export var clock = 0
var hour_length_seconds = 30
var time_checkpoint = 0

#Called when the node enters the scene tree for the first time.
func _ready():
	time_checkpoint = Time.get_ticks_msec()


#Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#calculate clock
	var current_time = Time.get_ticks_msec()
	var diff_seconds = (current_time - time_checkpoint) / 1000
	if(diff_seconds >= hour_length_seconds):
		time_checkpoint = Time.get_ticks_msec()
		if(clock != 23):
			clock = clock + 1
		else: if(clock == 23):
			clock = 0

	
