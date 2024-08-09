@tool
class_name NPC
extends RigidBody2D

#behavior Directives
const full_passive = "full_passive"
const alert_passive = "alert_passive"
const appears_at_time = "appears_at_time"

@export var talk_radius = 100
@export var has_passive_text = false
@export var has_monologue_text = false
@export var facingPosition = "left"
#@export var ai_directive = full_passive
@export var voice = "none"

@export var base_spriteframes : SpriteFrames
@export var hat_spriteframes : SpriteFrames
@export var top_spriteframes : SpriteFrames
@export var bottom_spriteframes : SpriteFrames
@export var facing_dir = "right"

#array of all schedules this NPC will use
@export var schedules : Array[schedule] = []
var schedules_index = 0 #TODO: find a way to iterate this through some kind of global gamestate

#@export var passive_text = ""

@export var shop : shop_manager = null
@export var branching_dialog : dialog_tree
var dialog = preload("res://dialog/dialog.tscn")
var dialog_manager : Node

@onready var _character_base = $character_base

#data type representing NPC's knowledge of itself and its surroundings
var perceptions: NPCPerceptions = NPCPerceptions.new()

#state machine reference
@onready var _ai_state_machine = $ai_state_machine

@onready var _navigation_agent: NavigationAgent2D = $NavigationAgent2D

var can_talk_bubble = preload("res://interface/can_talk_bubble.tscn")
var speech_bubble = preload("res://dialog/speech_bubble.tscn")
var talking = false
var has_talked = false
var showing_bubble = false

const top_speed = 125000
const nav_target_reached_distance = 32 #distance at which nav target is considered reached
const nav_path_resolution = 4

var sound_player := AudioStreamPlayer2D.new()

var bubble_instance = null
var speech_instance = null

var current_v = Vector2(0,0)
var immobilized = false

var player_ref

# Called when the node enters the scene tree for the first time.
func _ready():
	set_up_character_base()
	set_up_sound_player()
	set_up_nav_agent()
	update_perceptions()
	send_perceptions()
	
	if(Engine.is_editor_hint()):
		queue_redraw()

func set_up_character_base():
	_character_base.set_facing_dir(facing_dir)
	_character_base.set_spriteframes(base_spriteframes,
	hat_spriteframes,
	top_spriteframes,
	bottom_spriteframes)
	_character_base.stand_dir(_character_base.facing_dir)

func set_up_nav_agent():
	#nav agent setup stuff
	_navigation_agent.path_desired_distance = 4.0
	_navigation_agent.target_desired_distance = nav_target_reached_distance

func set_up_sound_player():
	sound_player.max_distance = 500
	sound_player.attenuation = 2
	sound_player.bus = "Effects"
	add_child(sound_player)

func send_perceptions():
	if(_ai_state_machine != null):
		_ai_state_machine.receive_perceptions(perceptions)

func update():
	update_perceptions()

func update_branching_dialog():
	if(schedules.size() > 0):
		branching_dialog = perceptions.current_stage_mark.get_branching_dialog()

func interact():
	if (branching_dialog != null):
		dialog_manager = dialog.instantiate()
		dialog_manager.set_speaker_node(self)
		add_child(dialog_manager)
		if(shop != null):
			dialog_manager.set_shop(shop)
		var player_ref = get_tree().get_nodes_in_group("player")[0]
		player_ref.enter_dialog()
		dialog_manager.set_tree_and_start_dialog(branching_dialog)	

func update_perceptions():
	perceptions.current_v = current_v
	perceptions.facing_dir = _character_base.get_facing_dir()
	perceptions.position = position
	perceptions.linear_velocity = linear_velocity
	perceptions.speed = linear_velocity.length()
	
	if(schedules.size() > 0):
		var time_keeper_ref = get_tree().get_first_node_in_group("time_keeper")
		if(time_keeper_ref != null):
			var current_schedule = schedules[schedules_index]
			var current_day_index = time_keeper_ref.get_day_of_week()
			var current_hour_index = time_keeper_ref.get_hour()
			var current_stage_mark = current_schedule.get_stage_mark(current_day_index,current_hour_index)
			perceptions.current_stage_mark = current_stage_mark

func get_branching_dialog():
	return branching_dialog

func get_shop_manager():
	return shop

func speed():
	return linear_velocity.length()

func handle_passive_text():
	var passive_text = perceptions.current_stage_mark.get_passive_text()
	if(passive_text != ""):
		var in_talk_radius = self.global_position.distance_to(player_ref.global_position) < talk_radius
		if(!player_ref.in_dialog && !talking && in_talk_radius && !has_talked):
			speech_instance = speech_bubble.instantiate()
			self.add_child(speech_instance)
			speech_instance.play_passive_text(passive_text, voice)
			has_talked = true
			talking = true
		elif (speech_instance != null && 
		player_ref.in_dialog || talking && speech_instance.ready_to_disappear):
			speech_instance.queue_free()
			talking = false
		
		if(!in_talk_radius):
			has_talked = false

func _on_set_branching_dialog(tree : dialog_tree):
	branching_dialog = tree

#func _on_set_ai_directive(directive : String):
	#ai_directive = directive

func _on_set_nav_target(pos : Vector2):
	perceptions.nav_target_reached = false
	_navigation_agent.target_position = pos

func _on_turn_right():
	_character_base.turn_right()
	perceptions.facing_dir = _character_base.get_facing_dir()
	
func _on_turn_left():
	_character_base.turn_left()
	perceptions.facing_dir = _character_base.get_facing_dir()

#move mobster along A* navigation path towards navigation target
#and animate accordingly
func _on_advance_navigation(speed : int):
	if (!perceptions.nav_target_reached &&
	global_position.distance_to(_navigation_agent.target_position) >= nav_target_reached_distance):
		var current_agent_position: Vector2 = global_position
		var next_path_position: Vector2 = _navigation_agent.get_next_path_position()
		current_v = current_agent_position.direction_to(next_path_position) * speed
	else:
		current_v = perceptions.current_v * 0
		perceptions.nav_target_reached = true
	#handle animation
	_character_base.face_to_vector(current_v)
	_character_base.animate_sprite_by_vector(current_v, (linear_velocity.length() >= top_speed))
	var base = 0.4
	var remainder = 0.6
	_character_base.set_animation_scale(base,remainder,perceptions.speed,top_speed)

func face_player():
	var vector_to_player = global_position.direction_to(player_ref.global_position)
	_character_base.face_to_vector(vector_to_player)

func _on_handle_behavior(behavior_directive : String):
	#alert passive NPC
	if(behavior_directive == alert_passive):
		if(self.global_position.distance_to(player_ref.global_position) < talk_radius):
			face_player()
		handle_passive_text()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(!Engine.is_editor_hint()):
		player_ref = get_tree().get_nodes_in_group("player")[0]
		update()
		send_perceptions()

func _physics_process(delta):
	if(!Engine.is_editor_hint()):
		if(!immobilized):
			_character_base.face_to_vector(current_v)
			_character_base.animate_sprite_by_vector(current_v, (speed() >= top_speed))
		else:
			current_v = current_v * 0
		
		#apply velocity thru physics engine
		apply_force(current_v)
