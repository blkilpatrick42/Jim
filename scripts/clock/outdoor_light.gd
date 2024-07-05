extends CanvasModulate

var time_keeper = null
var light_level = 1
var fade_time = 3.0
var timer_fade := Timer.new()
var fade_quotient = 0.0
var time_between_fades_secs = 1.0
var fading = false
var paused = false

var interpolation_gradient = Gradient.new()
var interpolation_points = 60
var interp_points_per_sec = 1
var timer_interpolation := Timer.new()

var colors := {
	0.0:      Color(0.514, 0.522, 0.667), #12:00am
	0.041666: Color(0.514, 0.522, 0.667), #1:00
	0.083332: Color(0.514, 0.522, 0.667), #2
	0.124998: Color(0.514, 0.522, 0.667), #3
	0.166664: Color(0.514, 0.522, 0.667), #4
	0.20833:  Color(0.514, 0.522, 0.667), #5
	0.249996: Color(0.753, 0.702, 0.796), #6
	0.291662: Color(0.961, 0.863, 0.933), #7
	0.333328: Color(1, 0.937, 0.98), #8
	0.374994: Color(1, 1, 1), #9
	0.41666:  Color(1, 1, 1), #10
	0.458326: Color(1, 1, 1), #11
	0.499992: Color(1, 1, 1), #12:00pm
	0.541658: Color(1, 1, 1), #1:00pm
	0.583324: Color(1, 1, 1), #2
	0.62499:  Color(1, 1, 1), #3
	0.666656: Color(1, 1, 1), #4
	0.708322: Color(0.961, 0.863, 0.933), #5
	0.749988: Color(0.871, 0.729, 0.847), #6
	0.791654: Color(0.573, 0.584, 0.702), #7
	0.83332:  Color(0.514, 0.522, 0.667), #8
	0.874986: Color(0.514, 0.522, 0.667), #9
	0.916652: Color(0.514, 0.522, 0.667), #10
	1.0:      Color(0.514, 0.522, 0.667), #11
}

# Called when the node enters the scene tree for the first time.
func _ready():
	timer_fade.one_shot = true
	add_child(timer_fade)
	timer_interpolation.one_shot = true
	add_child(timer_interpolation)
	visible = true
	time_keeper = get_tree().get_nodes_in_group("time_keeper")[0]
	set_color( Color(light_level,light_level,light_level,1) )
	interpolation_gradient.offsets = colors.keys()
	interpolation_gradient.colors = colors.values()
	

#TODO: eventually this will have to be moved I think, at least if we want
#it to be possible for the player to die in an indoor space. 
func fade_to_black():
	if(!fading):
		fading = true
		fade_quotient = light_level / fade_time
		timer_fade.start(time_between_fades_secs)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(!fading && !paused):
		var day_ratio = time_keeper.get_time_as_ratio_of_full_day()
		set_color(interpolation_gradient.sample(day_ratio))
	else: if (timer_fade.is_stopped() && light_level > 0):
		light_level = light_level - fade_quotient
		timer_fade.start(time_between_fades_secs)
		set_color( Color(light_level,light_level,light_level,1) )
