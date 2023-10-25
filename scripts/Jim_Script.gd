extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D

var acceleration_quotient = 25
var friction_quotient = 25
var current_acceleration = 0
var max_acceleration = 50
var top_velocity = 500
var facingPosition = "left"

func _process(_delta):
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
	var input_direction = Input.get_vector("left", "right", "up", "down")
	
	#ramp up acceleration if we have't hit max
	if(current_acceleration < max_acceleration && 
	   input_direction.length() != 0):
		current_acceleration = current_acceleration + acceleration_quotient 
	
	#stop accelerating if we hit max speed
	if(velocity.length() >= top_velocity): 
		current_acceleration = 0
	
	#apply acceleration and friction to velocity
	velocity = velocity + (input_direction * current_acceleration) - (velocity.normalized() * friction_quotient)

	#if velocity is below friction quotient, just stop Jim. 
	#Oherwise leftover friction makes him scoot backwards lol
	if(velocity.length() < friction_quotient): 
		velocity = velocity * 0

func _physics_process(delta):
	get_input()
	move_and_slide()
	
