extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D
@onready var _left_grab = $left_grab
@onready var _right_grab = $right_grab
@onready var _up_grab = $up_grab
@onready var _down_grab = $down_grab

@export var facingPosition = "left"

var friction_quotient = 10
var current_acceleration = 0
var acceleration_quotient = 20
var top_velocity = 175

var holding_object = false
var will_grab_object = null
var will_talk_npc = null
var grabbed_object = null
var control_frozen = false

signal player_pickup()

func _process(_delta):
	if(!control_frozen):
		if Input.is_action_pressed("right"):
			_animated_sprite.play("walk_right")
			facingPosition = "right"
		else: if Input.is_action_pressed("left"):
			_animated_sprite.play("walk_left")
			facingPosition = "left"
		else: if Input.is_action_pressed("up"):
			_animated_sprite.play("walk_up")
			facingPosition = "up"
		else: if Input.is_action_pressed("down"):
			_animated_sprite.play("walk_down")
			facingPosition = "down"
		else: if (facingPosition == "left"):
			_animated_sprite.play("stand_left")
			current_acceleration = 0
		else: if (facingPosition == "right"):
			_animated_sprite.play("stand_right")
			current_acceleration = 0
		else: if (facingPosition == "up"):
			_animated_sprite.play("stand_up")
			current_acceleration = 0
		else: if (facingPosition == "down"):
			_animated_sprite.play("stand_down")
			current_acceleration = 0

func get_input():
	if(!control_frozen):
		handle_pickup()
		handle_throw()
		move_jim()
	
func handle_pickup():
	if Input.is_action_just_pressed("pickup"):
			pick_up()
			
func handle_throw():
	if Input.is_action_just_pressed("throw"):
			throw()

func throw():
	if(holding_object):
		grabbed_object.throw(facingPosition)
		grabbed_object = null
		holding_object = false
		
func pick_up():
	if(will_grab_object != null && !holding_object):
		will_grab_object.pick_up()
		grabbed_object = will_grab_object
		holding_object = true
	else: if(holding_object):	
		grabbed_object.put_down()
		grabbed_object = null
		holding_object = false

func move_jim():
	var input_direction = Input.get_vector("left", "right", "up", "down")

	#ramp up acceleration if we have't hit max
	if(input_direction.length() != 0):
		current_acceleration = acceleration_quotient 

	#stop accelerating if we hit max speed
	if(velocity.length() >= top_velocity): 
		current_acceleration = 0

	#apply acceleration and friction to velocity
	velocity = velocity + (input_direction * current_acceleration) - (velocity.normalized() * friction_quotient)

	#if velocity is below friction quotient, just stop Jim. 
	#Oherwise leftover friction makes him scoot backwards lol
	if(velocity.length() < friction_quotient): 
		velocity = velocity * 0
		
	
	#scale animation to movement speed
	if(velocity.length() != 0):
		#Base speed of 40%. We ramp to 100% (full speed) using a ratio of 
		#speed/topspeed for the remaining 60%.	
		var baseScale = 0.4
		var velocityScale = velocity.length() / top_velocity
		var remainderScale = 0.6 * velocityScale
		var animationScale = baseScale + remainderScale
		_animated_sprite.set_speed_scale(animationScale)
	else:
		_animated_sprite.set_speed_scale(1)
#
func _physics_process(delta):
	get_input()
	move_and_slide()
	
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
	



