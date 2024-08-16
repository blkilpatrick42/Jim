extends Camera2D

var player_ref

const pan_x_max = 96
const pan_y_max = 96
var pan_timer := Timer.new()
var pan_step = 4
const pan_step_time_secs = 0.005
var camera_offset = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	player_ref = get_parent()
	pan_timer.one_shot = true
	add_child(pan_timer)
	pan_timer.start(pan_step_time_secs)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	handle_camera_pan()

func handle_camera_pan():
	var pan_direction = Input.get_vector("pan_left", "pan_right", "pan_up", "pan_down")
	if(player_ref.dialog_panning):
		pan_direction = Vector2(0,-1)
	if(player_ref.dead):
		pan_direction = Vector2(0,0)
	
	#add dead zone for joysticks
	if(pan_direction.x < 0.4 && pan_direction.x > -0.4):
		pan_direction.x = 0
	if(pan_direction.y < 0.4 && pan_direction.y > -0.4):
		pan_direction.y = 0
	
	if(pan_timer.is_stopped()):
		var destination_x = (pan_direction.x/abs(pan_direction.x)) * pan_x_max 
		var destination_y = (pan_direction.y/abs(pan_direction.y)) * pan_y_max
		#var max_vector = Vector2(pan_x_max,pan_y_max)
		
		var adj_x_step = pan_step
		var adj_y_step = pan_step
		var divisor = 3
		var x_edge = pan_x_max / divisor
		var y_edge = pan_x_max / divisor
		var edge_x_distance = pan_x_max - abs(camera_offset.x)
		var edge_y_distance = pan_y_max - abs(camera_offset.y)
		
		if(edge_x_distance < x_edge):
			adj_x_step = (abs(edge_x_distance)/x_edge) * pan_step
		if(edge_y_distance < y_edge):
			adj_y_step = (abs(edge_y_distance)/y_edge) * pan_step
			
		var ret_adj_x_step = pan_step
		var ret_adj_y_step = pan_step
		if(abs(camera_offset.x) < x_edge):
			ret_adj_x_step = ceil((abs(camera_offset.x)/x_edge) * pan_step)
		if(abs(camera_offset.y) < y_edge):
			ret_adj_y_step = ceil((abs(camera_offset.y)/y_edge) * pan_step)
		
		#pan x
		if(destination_x > 0):
			if(camera_offset.x < destination_x):
				camera_offset = camera_offset + Vector2(adj_x_step,0)
		elif(destination_x < 0):
			if(camera_offset.x > destination_x):
				camera_offset = camera_offset + Vector2(-adj_x_step,0)
		
		#return x to center
		if(pan_direction.x == 0):
			if(camera_offset.x > 0):
				camera_offset = camera_offset + Vector2(-ret_adj_x_step,0)
			elif(camera_offset.x < 0):
				camera_offset = camera_offset + Vector2(ret_adj_x_step,0)
			
		#pan y
		if(destination_y > 0):
			if(camera_offset.y < destination_y):
				camera_offset = camera_offset + Vector2(0,adj_y_step)
		elif(destination_y < 0):
			if(camera_offset.y > destination_y):
				camera_offset = camera_offset + Vector2(0,-adj_y_step)
			
		#return y to center
		if(pan_direction.y == 0):
			if(camera_offset.y > 0):
				camera_offset = camera_offset + Vector2(0,-ret_adj_y_step)
			elif(camera_offset.y < 0):
				camera_offset = camera_offset + Vector2(0,ret_adj_y_step)
		
			#snap to center
		if(pan_direction.x == 0 &&
		camera_offset.x < 1 && 
		camera_offset.x > -1):
			camera_offset.x = 0
		if(pan_direction.y == 0 &&
		camera_offset.y < 1 && 
		camera_offset.y > -1):
			camera_offset.y = 0
		
		pan_timer.start(pan_step_time_secs)
	
	set_offset(camera_offset)
