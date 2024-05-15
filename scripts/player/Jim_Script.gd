extends RigidBody2D

@onready var _animated_sprite = $AnimatedSprite2D
@onready var _left_grab = $left_grab
@onready var _right_grab = $right_grab
@onready var _up_grab = $up_grab
@onready var _down_grab = $down_grab
@export var facingPosition = "left"

const facing_pos_right = "right"
const facing_pos_left = "left"
const facing_pos_up = "up"
const facing_pos_down = "down"

var dash_get = preload("res://interface/dash_get.tscn")
var dust = preload("res://interface/dust.tscn")

var sound_player := AudioStreamPlayer.new()

var normal_speed = 50000
var dash_speed = 250000
var acceleration_quotient = normal_speed
var top_speed = 180

var can_dash = true
var is_dashing = false
var dash_timer= 0.5
var dash_regen_timer = 5
var dash_ticks_chkpt = 0

var holding_object = false
var will_grab_object = null
var will_talk_npc = null
var grabbed_object = null
var control_frozen = false
var current_v = Vector2(0,0)

signal player_pickup()

func _ready():
	add_child(sound_player)
	sound_player.volume_db = -12

func stand_dir(direction):
	match(direction):
		facing_pos_left:
			_animated_sprite.play("stand_left")
		facing_pos_right:
			_animated_sprite.play("stand_right")
		facing_pos_down:
			_animated_sprite.play("stand_down")
		facing_pos_up:
			_animated_sprite.play("stand_up")

func walk_dir(direction):
		match(direction):
			facing_pos_left:
				_animated_sprite.play("walk_left")
			facing_pos_right:
				_animated_sprite.play("walk_right")
			facing_pos_down:
				_animated_sprite.play("walk_down")
			facing_pos_up:
				_animated_sprite.play("walk_up")

#animate sprite based on velocity
func set_sprite_by_velocity():
	if(current_v.length() > 0 || speed() >= top_speed):
		walk_dir(facingPosition)
	else: 
		stand_dir(facingPosition)

func _process(_delta):
	set_sprite_by_velocity()
	will_grab_object = null
	if(!holding_object):
		var leftGrabObj = null
		var rightGrabObj = null
		var upGrabObj = null
		var downGrabObj = null
		
		if(_left_grab.is_colliding()):
			leftGrabObj = _left_grab.get_collider(0)
		else: if(_right_grab.is_colliding()):
			rightGrabObj = _right_grab.get_collider(0)
		else: if(_up_grab.is_colliding()):
			upGrabObj = _up_grab.get_collider(0)
		else: if(_down_grab.is_colliding()):
			downGrabObj = _down_grab.get_collider(0)
		
		#check for pickupables
		get_tree().call_group("pickupable", "set_will_pickup_false")
		if(facingPosition == "left" &&
		leftGrabObj != null && 
		leftGrabObj.is_in_group("pickupable")):
			leftGrabObj.will_pickup = true
			will_grab_object = leftGrabObj
		else: if(facingPosition == "right" &&
		rightGrabObj != null && 
		rightGrabObj.is_in_group("pickupable")):
			rightGrabObj.will_pickup = true
			will_grab_object = rightGrabObj
		else: if(facingPosition == "up" &&
		upGrabObj != null && 
		upGrabObj.is_in_group("pickupable")):
			upGrabObj.will_pickup = true
			will_grab_object = upGrabObj
		else: if(facingPosition == "down" &&
		downGrabObj != null && 
		downGrabObj.is_in_group("pickupable")):
			downGrabObj.will_pickup = true
			will_grab_object = downGrabObj
			
		#check for npcs
		get_tree().call_group("npc", "set_will_talk_false")
		if(facingPosition == "left" &&
		leftGrabObj != null && 
		leftGrabObj.is_in_group("npc")):
			leftGrabObj.will_talk = true
		else: if(facingPosition == "right" &&
		rightGrabObj != null && 
		rightGrabObj.is_in_group("npc")):
			rightGrabObj.will_talk = true
		else: if(facingPosition == "up" &&
		upGrabObj != null && 
		upGrabObj.is_in_group("npc")):
			upGrabObj.will_talk = true
		else: if(facingPosition == "down" &&
			downGrabObj != null && 
			downGrabObj.is_in_group("npc")):
			downGrabObj.will_talk = true
	
	#handle dash timer stuff
	var time_since_dash_secs = ((Time.get_ticks_msec() - dash_ticks_chkpt)/1000)
	if(is_dashing):
		acceleration_quotient = dash_speed
		if(time_since_dash_secs > dash_timer):
			is_dashing = false
			acceleration_quotient = normal_speed
	else:
		acceleration_quotient = normal_speed
	
	#regen dash
	if(time_since_dash_secs > dash_regen_timer && can_dash == false):
		sound_player.stream = load("res://audio/soundFX/dashget.wav")
		sound_player.play()
		can_dash = true
		add_child(dash_get.instantiate())

func get_input():
	if(!control_frozen):
				#orient and player according to input
		if Input.is_action_pressed("right"):
			facingPosition = facing_pos_right
		else: if Input.is_action_pressed("left"):
			facingPosition = facing_pos_left
		else: if Input.is_action_pressed("up"):
			facingPosition = facing_pos_up
		else: if Input.is_action_pressed("down"):
				facingPosition = facing_pos_down
		handle_pickup()
		handle_throw()
		handle_dash()
		move_jim()

func handle_pickup():
	if Input.is_action_just_pressed("pickup"):
			pick_up()

func handle_dash():
	if Input.is_action_just_pressed("dash"):
			dash()

func handle_throw():
	if Input.is_action_just_pressed("throw"):
			throw()

func throw():
	if(holding_object):
		sound_player.stream = load("res://audio/soundFX/woosh.wav")
		sound_player.play()
		grabbed_object.throw(facingPosition)
		grabbed_object = null
		holding_object = false

func pick_up():
	if(will_grab_object != null && !holding_object):
		sound_player.stream = load("res://audio/soundFX/pickup.wav")
		sound_player.play()
		will_grab_object.pick_up()
		grabbed_object = will_grab_object
		holding_object = true
	else: if(holding_object):
		sound_player.stream = load("res://audio/soundFX/putdown.wav")
		sound_player.play()
		grabbed_object.put_down(facingPosition)
		grabbed_object = null
		holding_object = false

func dash():
	if(!is_dashing && Input.get_vector("left", "right", "up", "down").length() > 0):
		if(can_dash):
			sound_player.stream = load("res://audio/soundFX/woosh.wav")
			sound_player.play()
#			var dash_dust = dust.instantiate()
			#add_child(dust.instantiate())
			#remove_child(dash_dust)
#			add_child(dash_dust)
			is_dashing = true
			can_dash = false
			dash_ticks_chkpt = Time.get_ticks_msec() 

func speed():
	return linear_velocity.length()

func move_jim():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	
	#accelerate if we have't hit max
	if(input_direction.length() != 0 && speed() < top_speed):
		current_v = input_direction * acceleration_quotient 
	else: 
		current_v = input_direction * 0
		
	#scale animation to movement speed
	if(speed() != 0):
		#Base speed of 40%. We ramp to 100% (full speed) using a ratio of 
		#speed/topspeed for the remaining 60%.	
		var baseScale = 0.2
		var velocityScale = speed() / top_speed
		var remainderScale = 0.8 * velocityScale
		var animationScale = baseScale + remainderScale
		_animated_sprite.set_speed_scale(animationScale)
	else:
		_animated_sprite.set_speed_scale(1)

func _physics_process(delta):
	get_input()
	apply_force(current_v)



