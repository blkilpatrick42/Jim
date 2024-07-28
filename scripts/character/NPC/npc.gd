@tool
extends RigidBody2D

#AI Directives
const full_passive = "full_passive"
const alert_passive = "alert_passive"
const appears_at_time = "appears_at_time"

@export var talk_radius = 100
@export var has_passive_text = false
@export var has_monologue_text = false
@export var facingPosition = "left"
@export var ai_directive = full_passive
@export var voice = "none"

@export var base_spriteframes : SpriteFrames
@export var hat_spriteframes : SpriteFrames
@export var top_spriteframes : SpriteFrames
@export var bottom_spriteframes : SpriteFrames
@export var facing_dir = "right"

@export var passive_text = ""
@export var monologue_text = ""

@export var branching_dialog : dialog_tree
var dialog = preload("res://dialog/dialog.tscn")
var dialog_manager : Node

@onready var _character_base = $character_base

var can_talk_bubble = preload("res://interface/can_talk_bubble.tscn")
var speech_bubble = preload("res://dialog/speech_bubble.tscn")
var talking = false
var has_talked = false
var showing_bubble = false
var is_walking = false

var sound_player := AudioStreamPlayer.new()

var bubble_instance = null
var speech_instance = null

var current_v = Vector2(0,0)
var top_speed = 200
var immobilized = false

var player_ref

# Called when the node enters the scene tree for the first time.
func _ready():
	sound_player.bus = "Effects"
	add_child(sound_player)
	
	#set up character base
	_character_base.set_facing_dir(facing_dir)
	_character_base.set_spriteframes(base_spriteframes,
	hat_spriteframes,
	top_spriteframes,
	bottom_spriteframes)
	
	_character_base.stand_dir(_character_base.facing_dir)
	
	if(Engine.is_editor_hint()):
		queue_redraw()

func interact():
	if (branching_dialog != null):
		dialog_manager = dialog.instantiate()
		dialog_manager.set_speaker_node(self)
		add_child(dialog_manager)
		var player_ref = get_tree().get_nodes_in_group("player")[0]
		player_ref.enter_dialog()
		dialog_manager.set_tree_and_start_dialog(branching_dialog)	

func speed():
	return linear_velocity.length()

func handle_passive_text():
	if(has_passive_text):
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

func face_player():
	var vector_to_player = global_position.direction_to(player_ref.global_position)
	_character_base.face_to_vector(vector_to_player)

func handle_ai_directive():
	#alert passive NPC
	if(ai_directive == alert_passive &&
	self.global_position.distance_to(player_ref.global_position) < talk_radius):
		face_player()
	handle_passive_text()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(!Engine.is_editor_hint()):
		player_ref = get_tree().get_nodes_in_group("player")[0]
		handle_ai_directive()

func _physics_process(delta):
	if(!Engine.is_editor_hint()):
		if(!immobilized):
			_character_base.face_to_vector(current_v)
			_character_base.animate_sprite_by_vector(current_v, (speed() >= top_speed))
		else:
			current_v = current_v * 0
		
		#apply velocity thru physics engine
		apply_force(current_v)
