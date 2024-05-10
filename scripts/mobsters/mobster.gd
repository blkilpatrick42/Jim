extends RigidBody2D

#AI STATES
const state_patrol = "patrol"
const sub_state_patrol_transit = "patrol_transit"
const sub_state_patrol_look = "patrol_look"
var patrol_look_time_secs = 3
@export var current_patrol_point = Node2D

#State vars
@export var state = state_patrol
@export var sub_state = sub_state_patrol_look

@onready var _animated_sprite = $AnimatedSprite2D
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@export var facingPosition = "left"

var sound_player := AudioStreamPlayer.new()
var current_v = Vector2(0,0)
var max_speed = 15000
var random = RandomNumberGenerator.new()

var timer_checkpoint = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	_animated_sprite.play("default")
	add_child(sound_player)
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 32.0
	call_deferred("actor_setup")
	state = state_patrol

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target

func stand_left():
	_animated_sprite.play("stand_left")
	facingPosition = "left"

func stand_right():
	_animated_sprite.play("stand_right")
	facingPosition = "right"

func stand_up():
	_animated_sprite.play("stand_up")
	facingPosition = "up"

func stand_down():
	_animated_sprite.play("stand_down")
	facingPosition = "down"
	
func walk_left():
	_animated_sprite.play("walk_left")
	facingPosition = "left"

func walk_right():
	_animated_sprite.play("walk_right")
	facingPosition = "right"

func walk_up():
	_animated_sprite.play("walk_up")
	facingPosition = "up"

func walk_down():
	_animated_sprite.play("walk_down")
	facingPosition = "down"

func stand_facing_pos():
	if(facingPosition == "up"):
		stand_up()
	else: if(facingPosition == "down"):
		stand_down()
	else: if(facingPosition == "left"):
		stand_left()
	else: if(facingPosition == "right"):
		stand_right()

func walk_facing_pos():
	if(facingPosition == "up"):
		walk_up()
	else: if(facingPosition == "down"):
		walk_down()
	else: if(facingPosition == "left"):
		walk_left()
	else: if(facingPosition == "right"):
		walk_right()

func stand():
	if(facingPosition == "left"):
		stand_left()
	else: if(facingPosition == "right"):
		stand_right()
	else: if(facingPosition == "down"):
		stand_down()
	else: if(facingPosition == "up"):
		stand_up()

func speed():
	return linear_velocity.length()

#rotate and animate sprite based on velocity
func set_sprite_by_velocity():
	#movement is greater on the x axis
	if(abs(linear_velocity.x) >= abs(linear_velocity.y)): 
		if(linear_velocity.x > 0):
			facingPosition = "right"
		else: if (linear_velocity.x < 0):
			facingPosition = "left"
	#movement is greater on the y axis
	else: if (abs(linear_velocity.x) <= abs(linear_velocity.y)): 
		if(linear_velocity.y > 0):
			facingPosition = "down"
		else: if (linear_velocity.y < 0):
			facingPosition = "up"
	
	if(current_v.length() > 0):
		walk_facing_pos()
	else: if (current_v.length() == 0):
		stand_facing_pos()

#############
#AI STATE CODE 
#\/\/\/\/\/\/\/
func patrol():
	if(sub_state == sub_state_patrol_transit):
		patrol_transit()
	else: if(sub_state == sub_state_patrol_look):
		patrol_look()

func patrol_transit():
	if (position.distance_to(navigation_agent.target_position) <= 32):
		timer_checkpoint = Time.get_ticks_msec()
		sub_state = sub_state_patrol_look

func patrol_look():
	if((((Time.get_ticks_msec() - timer_checkpoint) / 1000) > patrol_look_time_secs)):
		if(current_patrol_point.has_next_point):
			current_patrol_point = current_patrol_point.next_point
			set_movement_target(current_patrol_point.position)
			sub_state = sub_state_patrol_transit

#/\/\/\/\/\/\/\
#AI STATE CODE 
#############

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#scale animation to movement speed
	if(speed() != 0):
		#Base speed of 40%. We ramp to 100% (full speed) using a ratio of 
		#speed/topspeed for the remaining 60%.	
		var baseScale = 0.4
		var velocityScale = speed() / max_speed
		var remainderScale = 0.6 * velocityScale
		var animationScale = baseScale + remainderScale
		_animated_sprite.set_speed_scale(animationScale)
	else:
		_animated_sprite.set_speed_scale(1)
	
	#process AI state
	if(state == state_patrol):
		patrol()

func _physics_process(delta):
	#advance along path towards movement target
	if (position.distance_to(navigation_agent.target_position) >= 32):
		var current_agent_position: Vector2 = global_position
		var next_path_position: Vector2 = navigation_agent.get_next_path_position()
		current_v = current_agent_position.direction_to(next_path_position) * max_speed
	else:
		current_v = current_v * 0
	
	#set animation via velocity
	set_sprite_by_velocity()
	
	#apply velocity thru physics engine
	apply_force(current_v)
	
