extends CanvasModulate

var time_keeper = null
var light_level = 1
var fade_time = 3
var timer_fade := Timer.new()
var fade_quotient = 0
var fading = false

# Called when the node enters the scene tree for the first time.
func _ready():
	timer_fade.one_shot = true
	add_child(timer_fade)
	visible = true
	time_keeper = get_tree().get_nodes_in_group("time_keeper")[0]
	

func fade_to_black():
	fading = true
	fade_quotient = light_level / fade_time
	timer_fade.start(1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(!fading):
		var clock = time_keeper.clock
		match clock:
			0: 
				light_level = 0.6
			6: 
				light_level = 0.7
			7: 
				light_level = 0.8
			8: 
				light_level = 0.9
			9: 
				light_level = 1
			17: 
				light_level = 0.9
			18: 
				light_level = 0.8
			19: 
				light_level = 0.7
			20: 
				light_level = 0.6
	else: if (timer_fade.is_stopped() && light_level > 0):
		light_level = light_level - fade_quotient
		timer_fade.start(1)

	set_color( Color(light_level,light_level,light_level,1) )
