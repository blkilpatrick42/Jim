@tool
extends RigidBody2D

var sound_player := AudioStreamPlayer2D.new()

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var _head_collider = $head_shape

@export var current_patrol_point :Node2D = null

#mobster team
const team_red = "red"
const team_blu = "blu"
@export var team = team_red
var opposing_team 

#perceptors
@onready var _raycast: RayCast2D = $RayCast2D
@onready var _vision = $vision

#character composition
@onready var _character_base = $character_base
@export var base_spriteframes : SpriteFrames
@export var hat_spriteframes : SpriteFrames
@export var top_spriteframes : SpriteFrames
@export var bottom_spriteframes : SpriteFrames
@export var start_facing_dir = direction.right

var current_v = Vector2(0,0) #force applied this physics frame

#data type representing mobster's knowledge of itself and its surroundings
var perceptions: MobsterPerceptions = MobsterPerceptions.new()

#state machine reference
@onready var _ai_state_machine = $ai_state_machine

const top_speed = 125000
const nav_target_reached_distance = 32 #distance at which nav target is considered reached
const nav_path_resolution = 4

# Called when the node enters the scene tree for the first time.
func _ready():
	set_up_sound_player()
	set_up_nav_agent()
	set_up_character_base()
	set_up_mobster_team()
	#for updating character composition in the editor
	if(Engine.is_editor_hint()):
		queue_redraw()

func set_up_character_base():
	_character_base.set_facing_dir(start_facing_dir)
	_character_base.set_spriteframes(base_spriteframes,
	hat_spriteframes,
	top_spriteframes,
	bottom_spriteframes)

func set_up_nav_agent():
	#nav agent setup stuff
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = nav_target_reached_distance

func set_up_sound_player():
	sound_player.max_distance = 500
	sound_player.attenuation = 2
	add_child(sound_player)

func set_up_mobster_team():
	add_to_group(team)
	if(team == team_red):
		opposing_team = team_blu
	else: if (team == team_blu):
		opposing_team = team_red
	perceptions.team = team
	perceptions.opposing_team = opposing_team

#################################################################
#PERCEPTIONS- functions which deal with the mobster's perceptions
#################################################################

func send_perceptions():
	if(_ai_state_machine != null):
		_ai_state_machine.receive_perceptions(perceptions)

func update_perceptions():
	perceptions.current_v = current_v
	perceptions.facing_dir = _character_base.get_facing_dir()
	perceptions.position = position
	perceptions.linear_velocity = linear_velocity
	perceptions.speed = linear_velocity.length()
	
	detect_sparks()
	
	#check if currently playing one-shot animation has ended
	if(perceptions.one_shot_animating &&
	_character_base.get_base_current_frame() == _character_base.get_base_animation_framecount() - 1):
		perceptions.one_shot_animating = false

func _on_body_entered(body: Node):
	perceptions.colliding_nodes.append(body)

func _on_body_exited(body: Node):
	var node_index = perceptions.colliding_nodes.find(body)
	perceptions.colliding_nodes.remove_at(node_index)
	
func detect_sparks():
	var sparks = get_tree().get_nodes_in_group("spark")
	var detection_distance = 16
	for spark in sparks:
		if(is_instance_valid(spark) &&
			spark not in perceptions.colliding_nodes &&
			spark.position.distance_to(position) < detection_distance):
				perceptions.colliding_nodes.append(spark)
	
	#clean out null nodes
	var iter = 0
	while iter < len(perceptions.colliding_nodes):
		if not is_instance_valid(perceptions.colliding_nodes[iter]):
			perceptions.colliding_nodes.remove_at(iter)
		else:
			iter += 1

#######################################################################################
#ACTIONS- signal functions that cause the mobster to take some action in the game world
#######################################################################################

func _on_set_nav_target(pos : Vector2):
	perceptions.nav_target_reached = false
	navigation_agent.target_position = pos

#move mobster along A* navigation path towards navigation target
#and animate accordingly
func _on_advance_navigation():
	if (position.distance_to(navigation_agent.target_position) >= nav_target_reached_distance):
		perceptions.nav_target_reached = false
		var current_agent_position: Vector2 = global_position
		var next_path_position: Vector2 = navigation_agent.get_next_path_position()
		current_v = current_agent_position.direction_to(next_path_position) * top_speed
	else:
		current_v = perceptions.current_v * 0
		perceptions.nav_target_reached = true
	#handle animation
	_character_base.face_to_vector(current_v)
	_character_base.animate_sprite_by_vector(current_v, (linear_velocity.length() >= top_speed))
	_character_base.set_animation_scale(0.4, 0.6,perceptions.speed,top_speed)

func _on_turn_right():
	_character_base.turn_right()
	
func _on_turn_left():
	_character_base.turn_left()

func _on_stand_dir(stand : String):
	if(stand == ""):
		_character_base.stand_dir(perceptions.facing_dir)
		_character_base.set_animation_scale(0.4, 0.6,perceptions.speed,top_speed)
	else:
		_character_base.stand_dir(stand)
		_character_base.set_animation_scale(0.4, 0.6,perceptions.speed,top_speed)

func _on_play_one_shot_animation(animation_name: String):
	if(perceptions.one_shot_animating == false):
		perceptions.one_shot_animating = true
		_character_base.play_animation(animation_name)

func _on_play_animation(animation_name: String):
	_character_base.play_animation(animation_name)

func _on_disable_head_collider():
	_head_collider.disabled = true

func _on_enable_head_collider():
	_head_collider.disabled = false

func _on_stop_motion():
	_character_base.set_animation_scale_ratio(1)
	current_v = Vector2(0,0)

##########################################################################################
#MAINTENENCE- functions that maintain the mobster's physical and observational consistency
##########################################################################################

func update():
	update_vision()
	update_perceptions()


func update_vision():
	match(_character_base.get_facing_dir()):
		direction.right:
			_vision.set_rotation_degrees(0) 
		direction.left:
			_vision.set_rotation_degrees(180)
		direction.up:
			_vision.set_rotation_degrees(270)
		direction.down:
			_vision.set_rotation_degrees(90)
			

##############
#PROCESS STUFF
##############

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(!Engine.is_editor_hint()):
		update()
		send_perceptions()

func _physics_process(delta):
	if(!Engine.is_editor_hint()):
		#apply velocity thru physics engine
		apply_force(current_v)
