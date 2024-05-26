@tool
extends RigidBody2D

@export var alertable = true

var question_bubble = preload("res://entities/mobsters/question.tscn")
var exclaim_bubble = preload("res://entities/mobsters/exclaim.tscn")
var bullet = preload("res://entities/mobsters/bullet.tscn")
var sound_player := AudioStreamPlayer2D.new()

const team_blu = "blu"
const team_red = "red"

var safe_velocity = Vector2(0,0)

#AI STATES
const state_inert = "inert"

#Patrol state
const state_patrol = "patrol"
const sub_state_patrol_transit = "patrol_transit"
const sub_state_patrol_look = "patrol_look"
var patrol_look_time_secs = 1
var timer_look := Timer.new() 
var patrol_look_turns = 0
@export var current_patrol_point :Node2D = null

#knockout state
const state_knockout = "knockout"
const sub_state_knockout_falling = "knockout_falling"
const sub_state_knockout_sleep = "knockout_sleep"
const sub_state_knockout_recover = "knockout_recover"
var knockout_sleep_time_secs = 10
var timer_knockout_sleep := Timer.new() 

#investigate state
const state_investigate = "investigate"
const sub_state_investigate_question = "investigate_question"
var investigate_question_time_secs = 3
var timer_investigate_question := Timer.new() 

#alert state
const state_alert = "alert"
const sub_state_alert_exclaiming = "alert_exclaim"
const sub_state_alert_shoot_gun = "alert_shoot_gun"
const alert_exclaim_time_secs = 1
var timer_alert_exclaim := Timer.new() 
var alert_target = null

#gun-related variables
const bust_num_sweeps = 2
const burst_bullets_per_sweep = 4
const burst_num_bullets = bust_num_sweeps * burst_bullets_per_sweep
const burst_cool_down_secs = 2
var timer_burst_cool_down := Timer.new() 
const time_between_shots_secs = 0.3
var timer_between_shots := Timer.new() 
const shoot_arc_degrees = 40 #keep it even
var num_bullets_fired = 0
var lower_bound = 0
var upper_bound = 0
var reverse_sweep = false
var burst_cool_down = false

#states where the mobster is vulnerable to being knocked out
var fall_vulnerable_states = [state_patrol, state_investigate]

#states where the mobster is able to become alerted
var alertable_states = [state_patrol, state_investigate]

#groups which will send mobster into alert state
var alertable_groups = ["player"]

#enemy the mobster is "targeting"
var AI_target_pos = Vector2(0,0) #last point where the target was seen
var AI_target_obj = null #reference to the target itself

#radius for which navigation targets are considered "reached"
var nav_target_reached = 32

#distance at which sparks will cause mobsters to be knocked out
var spark_knockout_distance = 16

#State vars
@export var state = state_patrol
@export var sub_state = sub_state_patrol_look

@onready var _character_base = $character_base
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var _raycast: RayCast2D = $RayCast2D
@onready var _vision = $vision
@onready var _shadow = $shadow
@onready var _head_collider = $head_shape

@export var base_spriteframes : SpriteFrames
@export var hat_spriteframes : SpriteFrames
@export var top_spriteframes : SpriteFrames
@export var bottom_spriteframes : SpriteFrames
@export var facing_dir = "right"

var current_v = Vector2(0,0) #The force which will be applied to the mobster this frame
var top_speed = 125000
var random = RandomNumberGenerator.new()

var immobilized = false

# Called when the node enters the scene tree for the first time.
func _ready():
	sound_player.max_distance = 500
	sound_player.attenuation = 2
	add_child(sound_player)
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 32.0
	initialize_timers()
	call_deferred("actor_setup") #set up navigation
	
	#set up character base
	_character_base.set_facing_dir(facing_dir)
	_character_base.set_spriteframes(base_spriteframes,
	hat_spriteframes,
	top_spriteframes,
	bottom_spriteframes)
	
	if(Engine.is_editor_hint()):
		queue_redraw()

func initialize_timers():
	timer_look.one_shot = true
	timer_knockout_sleep.one_shot = true
	timer_investigate_question.one_shot = true
	timer_alert_exclaim.one_shot = true
	timer_burst_cool_down.one_shot = true
	timer_between_shots.one_shot = true
	add_child(timer_look)
	add_child(timer_knockout_sleep)
	add_child(timer_investigate_question)
	add_child(timer_alert_exclaim)
	add_child(timer_burst_cool_down)
	add_child(timer_between_shots)

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target

func fall():
	immobilized = true
	state = state_knockout
	_head_collider.disabled = true
	sub_state = sub_state_knockout_falling
	timer_knockout_sleep.start(knockout_sleep_time_secs)
	_character_base.play_animation(str("fall_",_character_base.facing_dir))

func recover():
	sub_state = sub_state_knockout_recover
	_head_collider.disabled = false
	_character_base.play_animation(str("recover_",_character_base.facing_dir))

func face_AI_target_pos():
	var vector_to_target = position.direction_to(AI_target_pos)
	_character_base.face_to_vector(vector_to_target)

func speed():
	return linear_velocity.length()

func create_question_bubble():
	var questionBubble = question_bubble.instantiate()
	self.add_child(questionBubble)

func create_exclaim_bubble():
	var exclaimBubble = exclaim_bubble.instantiate()
	self.add_child(exclaimBubble)

func update_vision():
	match(_character_base.get_facing_dir()):
		_character_base.facing_dir_right:
			_vision.set_rotation_degrees(0) 
		_character_base.facing_dir_left:
			_vision.set_rotation_degrees(180)
		_character_base.facing_dir_up:
			_vision.set_rotation_degrees(270)
		_character_base.facing_dir_down:
			_vision.set_rotation_degrees(90)

func go_alert():
	sound_player.stream = load("res://audio/soundFX/alert.wav")
	sound_player.play()
	immobilized = true
	_character_base.stand_dir(_character_base.get_facing_dir())
	create_exclaim_bubble()
	state = state_alert
	sub_state = sub_state_alert_exclaiming
	timer_alert_exclaim.start(alert_exclaim_time_secs)

func leave_alert():
	sound_player.stream = load("res://audio/soundFX/voice/sine_voice/1.wav")
	sound_player.play()
	immobilized = false
	create_question_bubble()
	state = state_patrol
	sub_state = sub_state_patrol_look

func set_shoort_arc_bounds():
	var half_arc = shoot_arc_degrees / 2
	match(_character_base.get_facing_dir()):
		_character_base.facing_dir_right:
			lower_bound = 0 - half_arc
			upper_bound = 0 + half_arc
		_character_base.facing_dir_left:
			lower_bound = 180 - half_arc
			upper_bound = 180 + half_arc
		_character_base.facing_dir_up:
			lower_bound = 270 - half_arc
			upper_bound = 270 + half_arc
		_character_base.facing_dir_down:
			lower_bound = 90 - half_arc
			upper_bound = 90 + half_arc
	

func create_bullet():
	var bullet_spawn_point = position
	var half_arc = shoot_arc_degrees / 2
	var spawn_distance = 20
	var gun_pos_tweak = 5
	match(_character_base.get_facing_dir()):
		_character_base.facing_dir_right:
			bullet_spawn_point = bullet_spawn_point + Vector2(spawn_distance,0)
		_character_base.facing_dir_left:
			bullet_spawn_point = bullet_spawn_point + Vector2(-spawn_distance,0)
		_character_base.facing_dir_up:
			bullet_spawn_point = bullet_spawn_point + Vector2(gun_pos_tweak,-spawn_distance)
		_character_base.facing_dir_down:
			bullet_spawn_point = bullet_spawn_point + Vector2(-gun_pos_tweak,spawn_distance)
	
	var new_bullet = bullet.instantiate()
	get_parent().add_child(new_bullet)
	
	var arc_segment_degrees = shoot_arc_degrees / burst_bullets_per_sweep
	var current_segment = num_bullets_fired 
	while(current_segment > burst_bullets_per_sweep):
		reverse_sweep = !reverse_sweep
		current_segment = current_segment - burst_bullets_per_sweep
	
	var current_arc = 0
	if(reverse_sweep):
		current_arc = (upper_bound - (arc_segment_degrees * current_segment))
	else:
		current_arc = (lower_bound + (arc_segment_degrees * current_segment))
	
	new_bullet.rotation_degrees = current_arc
	new_bullet.position = bullet_spawn_point
	new_bullet.apply_velocity()
	new_bullet.create_spark_benign() #muzzle flash
	sound_player.stream = load("res://audio/soundFX/gunshot.wav")
	sound_player.play()

func shoot_burst():
	immobilized = true
	_character_base.play_animation(str("shoot_",_character_base.get_facing_dir()))
	
	if(timer_between_shots.is_stopped() 
		&& num_bullets_fired < burst_num_bullets):
		create_bullet()
		num_bullets_fired = num_bullets_fired + 1
		timer_between_shots.start(time_between_shots_secs)
	else: if(num_bullets_fired >= burst_num_bullets):
		burst_cool_down = true
		timer_burst_cool_down.start(burst_cool_down_secs)

func has_line_of_sight_to_object(obj):
	_raycast.set_target_position(obj.global_position - _raycast.global_position)
	if(_raycast.is_colliding() && _raycast.get_collider() == obj):
		return true
	else:
		return false

func check_vision():
	if(state in alertable_states):
		if (_vision.is_colliding()):
			var iterator = 0
			while(iterator < _vision.get_collision_count()):
				var entity = _vision.get_collider(iterator)
				if(entity != null):
					for group in alertable_groups:
						if(entity.is_in_group(group) &&
						has_line_of_sight_to_object(entity) &&
						alertable &&
						state != state_alert):
							go_alert()
							AI_target_obj = entity
							AI_target_pos = AI_target_obj.position
				iterator = iterator + 1

func advance_navigation():
	var mobsters = get_tree().get_nodes_in_group("mobster")
	var mobster_near_target = false
	for mob in mobsters:
		if(navigation_agent.target_position.distance_to(mob.position) <= nav_target_reached):
			mobster_near_target = true
		else:
			mobster_near_target = false
		#advance along path towards movement target
	if (position.distance_to(navigation_agent.target_position) >= nav_target_reached && !mobster_near_target):
		var current_agent_position: Vector2 = global_position
		var next_path_position: Vector2 = navigation_agent.get_next_path_position()
		current_v = current_agent_position.direction_to(next_path_position) * top_speed
	else:
		current_v = current_v * 0

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
		timer_look.start(patrol_look_time_secs)
		patrol_look_turns = 0
		sub_state = sub_state_patrol_look

func patrol_look():
	var num_look_turns = 4 #complete rotation
	if(timer_look.is_stopped()):
		timer_look.start(patrol_look_time_secs)
		if(patrol_look_turns < num_look_turns):
			patrol_look_turns = patrol_look_turns + 1
			_character_base.turn_right()
		else: 
			patrol_look_turns = 0
			if(current_patrol_point != null &&
			current_patrol_point.has_next_point &&
			!current_patrol_point.next_point.is_occupied()):
				current_patrol_point = current_patrol_point.next_point
				set_movement_target(current_patrol_point.position)
				sub_state = sub_state_patrol_transit
			else: if(current_patrol_point == null):
				patrol_look_turns = 4
#KNOCKOUT STATE
func knockout():
	match(sub_state):
		sub_state_knockout_falling:
			knockout_falling()
		sub_state_knockout_sleep:
			knockout_sleep()
		sub_state_knockout_recover:
			knockout_recovering()

func knockout_falling():
	#NOTE THAT THIS WILL BREAK IF ALL FALLING ANIMATIONS DO NOT HAVE EQUIVALENT FRAMECOUNTS
	if(_character_base.get_base_current_frame() == _character_base.get_base_animation_framecount("fall_right")-1):
		sound_player.stream = load("res://audio/soundFX/bigCollide.wav")
		sound_player.play()
		sub_state = sub_state_knockout_sleep
		_character_base.play_animation(str("fallen_",_character_base.get_facing_dir()))

func knockout_sleep():
	if(timer_knockout_sleep.is_stopped()):
		recover()

func knockout_recovering():
	if(_character_base.get_base_current_frame()  == _character_base.get_base_animation_framecount("recover_right")-1):
		state = state_patrol
		sub_state = sub_state_patrol_look
		immobilized = false

#INVESTIGATE STATE
func investigate():
	match(sub_state):
		sub_state_investigate_question:
			investigate_question()

func investigate_question():
	if(timer_investigate_question.is_stopped()):
		state = state_patrol
		sub_state = sub_state_patrol_look
		immobilized = false

#ALERT STATE
func alert():
	match(sub_state):
		sub_state_alert_exclaiming:
			alert_exclaiming()
		sub_state_alert_shoot_gun:
			alert_shooting()

func alert_exclaiming():
	#TODO: state should go into alert attack mode
	if(timer_alert_exclaim.is_stopped()):
		sub_state = sub_state_alert_shoot_gun
		burst_cool_down = false
		set_shoort_arc_bounds()

func alert_shooting():
	if(has_line_of_sight_to_object(AI_target_obj)):
		AI_target_pos = AI_target_obj.position
		face_AI_target_pos()
		set_shoort_arc_bounds()
		
	if(!burst_cool_down):
		shoot_burst()
	else: if(timer_burst_cool_down.is_stopped()):
		num_bullets_fired = 0
		burst_cool_down = false
		if(!has_line_of_sight_to_object(AI_target_obj)):
			leave_alert()
		

#/\/\/\/\/\/\/\
#AI STATE CODE 
#############

func _process(delta):
	if(!Engine.is_editor_hint()):
		check_vision()
		
		#process AI state
		handle_AI()
		
		if(!immobilized):
			_character_base.set_animation_scale(0.4, 0.6,speed(),top_speed)
		
		update_vision()
		
		var sparks = get_tree().get_nodes_in_group("spark")
		for spark in sparks:
			if (global_position.distance_to(spark.global_position) < spark_knockout_distance &&
				state in fall_vulnerable_states):
				fall()

func _physics_process(delta):
	if(!Engine.is_editor_hint()):
		if(!immobilized):
			_character_base.face_to_vector(current_v)
			_character_base.animate_sprite_by_vector(current_v, (speed() >= top_speed))
			advance_navigation()
		else:
			current_v = current_v * 0
		
		#apply velocity thru physics engine
		apply_force(current_v)

