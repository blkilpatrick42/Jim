extends RigidBody2D

#AI STATES
const patrol = "patrol"

@onready var _animated_sprite = $AnimatedSprite2D
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@export var facingPosition = "left"

var sound_player := AudioStreamPlayer.new()
var current_v = Vector2(0,0)
var max_speed = 15000

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

func set_sprite_by_velocity():
	if(abs(linear_velocity.x) >= abs(linear_velocity.y)): #movement is greater on the x axis
		if(linear_velocity.x > 0):
			facingPosition = "right"
		else: if (linear_velocity.x < 0):
			facingPosition = "left"
	else: if (abs(linear_velocity.x) <= abs(linear_velocity.y)): #movement is greater on the y axis
		if(linear_velocity.y > 0):
			facingPosition = "down"
		else: if (linear_velocity.y < 0):
			facingPosition = "up"
	
	if(current_v.length() > 0):
		walk_facing_pos()
	else: if (current_v.length() == 0):
		stand_facing_pos()

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
		
	set_movement_target(get_tree().get_first_node_in_group("player").position)
	
#	if(position.distance_to(get_tree().get_first_node_in_group("player").position) > 32):
#		set_movement_target(position.direction_to(get_tree().get_first_node_in_group("player").position)
#		current_v = position.direction_to(get_tree().get_first_node_in_group("player").position) * max_speed
#	else:
#		current_v = current_v * 0
	
func _physics_process(delta):
	if (position.distance_to(navigation_agent.target_position) >= 32):
		var current_agent_position: Vector2 = global_position
		var next_path_position: Vector2 = navigation_agent.get_next_path_position()
		current_v = current_agent_position.direction_to(next_path_position) * max_speed
	else:
		current_v = current_v * 0

	set_sprite_by_velocity()
	apply_force(current_v)
	
