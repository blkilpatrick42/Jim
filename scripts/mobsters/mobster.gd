extends RigidBody2D

var question_bubble = preload("res://entities/mobsters/question.tscn")
var exclaim_bubble = preload("res://entities/mobsters/exclaim.tscn")

const milliseconds_in_second = 1000

const facing_pos_right = "right"
const facing_pos_left = "left"
const facing_pos_up = "up"
const facing_pos_down = "down"

const team_blu = "blu"
const team_red = "red"

#AI STATES
#Patrol state
const state_patrol = "patrol"
const sub_state_patrol_transit = "patrol_transit"
const sub_state_patrol_look = "patrol_look"
var patrol_look_time_secs = 1
var patrol_look_turns = 0
@export var current_patrol_point = Node2D

#knockout state
const state_knockout = "knockout"
const sub_state_knockout_falling = "knockout_falling"
const sub_state_knockout_sleep = "knockout_sleep"
const sub_state_knockout_recover = "knockout_recover"
var knockout_sleep_time_secs = 10

#investigate state
const state_investigate = "investigate"
const sub_state_investigate_question = "investigate_question"
var investigate_question_time_secs = 3

#alert state
const state_alert = "alert"
const sub_state_alert_exclaiming = "alert_exclaim"
const sub_state_alert_attack = "alert_attack"
var alert_exclaim_time_secs = 3
var alert_target = null

#states where the mobster is vulnerable to being knocked out
var fall_vulnerable_states = [state_patrol, state_investigate]

#states where the mobster is able to become alerted
var alertable_states = [state_patrol, state_investigate]

#enemy the mobster is "targeting"
var AI_target_pos = Vector2(0,0)

#radius for which navigation targets are considered "reached"
var nav_target_reached = 32

#distance at which sparks will cause mobsters to be knocked out
var spark_knockout_distance = 16

#State vars
@export var state = state_patrol
@export var sub_state = sub_state_patrol_look

@onready var _animated_sprite = $AnimatedSprite2D
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var _raycast: RayCast2D = $RayCast2D
@onready var _vision = $vision
@onready var _shadow = $shadow


@export var facingPosition = facing_pos_left

var sound_player := AudioStreamPlayer.new()
var current_v = Vector2(0,0)
var max_speed = 125000
var random = RandomNumberGenerator.new()

var immobilized = false

var timer_checkpoint = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	_animated_sprite.play("default")
	add_child(sound_player)
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 32.0
	call_deferred("actor_setup")

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target

func fall():
	immobilized = true
	state = state_knockout
	sub_state = sub_state_knockout_falling
	make_timer_checkpoint()
	_animated_sprite.play(str("fall_",facingPosition))

func recover():
	sub_state = sub_state_knockout_recover
	_animated_sprite.play(str("recover_",facingPosition))

func stand_dir(direction):
	_animated_sprite.play(str("stand_",facingPosition))

func walk_dir(direction):
	_animated_sprite.play(str("walk_",facingPosition))

func turn_right():
	match(facingPosition):
		facing_pos_right:
			facingPosition = facing_pos_down
		facing_pos_down:
			facingPosition = facing_pos_left
		facing_pos_left:
			facingPosition = facing_pos_up
		facing_pos_up:
			facingPosition = facing_pos_right

func turn_left():
	match(facingPosition):
		facing_pos_right:
			facingPosition = facing_pos_up
		facing_pos_down:
			facingPosition = facing_pos_right
		facing_pos_left:
			facingPosition = facing_pos_down
		facing_pos_up:
			facingPosition = facing_pos_left

func speed():
	return linear_velocity.length()

func create_question_bubble():
	var questionBubble = question_bubble.instantiate()
	self.add_child(questionBubble)

func create_exclaim_bubble():
	var exclaimBubble = exclaim_bubble.instantiate()
	self.add_child(exclaimBubble)

#rotate and animate sprite based on velocity
func set_sprite_by_velocity():
	#movement is greater on the x axis
	if(abs(current_v.x) >= abs(current_v.y)): 
		if(current_v.x > 0):
			facingPosition = facing_pos_right
		else: if (current_v.x < 0):
			facingPosition = facing_pos_left
	#movement is greater on the y axis
	else: if (abs(current_v.x) <= abs(current_v.y)): 
		if(current_v.y > 0):
			facingPosition = facing_pos_down
		else: if (current_v.y < 0):
			facingPosition = facing_pos_up
	
	if(current_v.length() > 0):
		walk_dir(facingPosition)
	else: 
		stand_dir(facingPosition)

func update_vision():
	match(facingPosition):
		facing_pos_right:
			_vision.set_rotation_degrees(0) 
		facing_pos_left:
			_vision.set_rotation_degrees(180)
		facing_pos_up:
			_vision.set_rotation_degrees(270)
		facing_pos_down:
			_vision.set_rotation_degrees(90)

func go_alert():
	immobilized = true
	stand_dir(facingPosition)
	create_exclaim_bubble()
	state = state_alert
	sub_state = sub_state_alert_exclaiming
	make_timer_checkpoint()

func check_vision():
	if (_vision.is_colliding()):
		var iterator = 0
		while(iterator < _vision.get_collision_count()):
			var entity = _vision.get_collider(iterator)
			if(entity.is_in_group("player") && state in alertable_states):
				_raycast.set_target_position(entity.global_position - _raycast.global_position)
				if(_raycast.is_colliding() &&
				   _raycast.get_collider() == entity):
					go_alert()
			iterator = iterator + 1

func advance_navigation():
		#advance along path towards movement target
	if (position.distance_to(navigation_agent.target_position) >= nav_target_reached):
		var current_agent_position: Vector2 = global_position
		var next_path_position: Vector2 = navigation_agent.get_next_path_position()
		current_v = current_agent_position.direction_to(next_path_position) * max_speed
	else:
		current_v = current_v * 0

#returns seconds since last time checkpoint
func get_checkpoint_secs_elapsed():
	return (Time.get_ticks_msec() - timer_checkpoint) / milliseconds_in_second

func make_timer_checkpoint():
	timer_checkpoint = Time.get_ticks_msec()

#############
#AI STATE CODE 
#\/\/\/\/\/\/\/
#PATROL STATE
func handle_AI():
	match(state):
		state_patrol:
			patrol()
		state_knockout:
			knockout()
		state_alert:
			alert()
		state_investigate:
			investigate()

func patrol():
	match(sub_state):
		sub_state_patrol_transit:
			patrol_transit()
		sub_state_patrol_look:
			patrol_look()

func patrol_transit():
	if (position.distance_to(navigation_agent.target_position) <= nav_target_reached):
		make_timer_checkpoint()
		patrol_look_turns = 0
		sub_state = sub_state_patrol_look

func patrol_look():
	var num_look_turns = 4 #complete rotation
	if((get_checkpoint_secs_elapsed() > patrol_look_time_secs)):
		timer_checkpoint = Time.get_ticks_msec()
		if(patrol_look_turns < num_look_turns):
			patrol_look_turns = patrol_look_turns + 1
			turn_right()
		else: 
			patrol_look_turns = 0
			if(current_patrol_point.has_next_point):
				current_patrol_point = current_patrol_point.next_point
				set_movement_target(current_patrol_point.position)
			sub_state = sub_state_patrol_transit

#KNOCKOUT STATE
func knockout():
	match(sub_state):
		sub_state_knockout_falling:
			falling()
		sub_state_knockout_sleep:
			sleep()
		sub_state_knockout_recover:
			recovering()

func falling():
	#NOTE THAT THIS WILL BREAK IF ALL FALLING ANIMATIONS DO NOT HAVE EQUIVALENT FRAMECOUNTS
	if(_animated_sprite.frame == _animated_sprite.sprite_frames.get_frame_count("fall_right")-1):
		sub_state = sub_state_knockout_sleep
		match(facingPosition):
			facing_pos_left:
				_animated_sprite.play("fallen_left")
			facing_pos_right:
				_animated_sprite.play("fallen_right")
			facing_pos_down:
				_animated_sprite.play("fallen_down")
			facing_pos_up:
				_animated_sprite.play("fallen_up")

func sleep():
	if(get_checkpoint_secs_elapsed() >= knockout_sleep_time_secs):
		recover()

func recovering():
	if(_animated_sprite.frame == _animated_sprite.sprite_frames.get_frame_count("recover_right")-1):
		state = state_patrol
		sub_state = sub_state_patrol_look
		immobilized = false

#INVESTIGATE STATE
func investigate():
	match(sub_state):
		sub_state_investigate_question:
			question()

func question():
	if(get_checkpoint_secs_elapsed() >= investigate_question_time_secs):
		state = state_patrol
		sub_state = sub_state_patrol_look
		immobilized = false

#ALERT STATE
func alert():
	if(sub_state == sub_state_alert_exclaiming):
		exclaiming()

func exclaiming():
	#TODO: state should go into alert attack mode
	if(get_checkpoint_secs_elapsed() >= alert_exclaim_time_secs):
		state = state_patrol
		sub_state = sub_state_patrol_look
		immobilized = false

#/\/\/\/\/\/\/\
#AI STATE CODE 
#############

func _process(delta):
	if(!immobilized):
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
	else:
		_animated_sprite.set_speed_scale(1)
	
	update_vision()
	
	var sparks = get_tree().get_nodes_in_group("spark")
	for spark in sparks:
		if (global_position.distance_to(spark.global_position) < spark_knockout_distance &&
			state in fall_vulnerable_states):
			fall()

func _physics_process(delta):
	check_vision()
	
	#process AI state
	handle_AI()
	
	if(!immobilized):
		set_sprite_by_velocity()
		advance_navigation()
	else:
		current_v = current_v * 0
	
	#apply velocity thru physics engine
	apply_force(current_v)
	