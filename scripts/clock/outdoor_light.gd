extends CanvasModulate

var time_keeper = null
var light_level = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = true
	time_keeper = get_tree().get_nodes_in_group("time_keeper")[0]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var clock = time_keeper.clock
	var red_lvl = 1
	var grn_lvl = 1
	var blu_lvl = 1
	
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

	set_color( Color(light_level,light_level,light_level,1) )
