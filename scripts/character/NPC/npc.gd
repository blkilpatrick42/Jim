@tool
extends RigidBody2D

#AI Directives
const full_passive = "full_passive"
const alert_passive = "alert_passive"

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

@onready var _character_base = $character_base

var can_talk_bubble = preload("res://interface/can_talk_bubble.tscn")
var speech_bubble = preload("res://interface/speech_bubble.tscn")
var talking = false
var will_talk = false
var showing_bubble = false
var is_walking = false

var sound_player := AudioStreamPlayer.new()

var bubble_instance = null
var speech_instance = null

var current_v = Vector2(0,0)
var top_speed = 200
var immobilized = false

# Called when the node enters the scene tree for the first time.
func _ready():
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
	
func set_will_talk_false():
	will_talk = false

func speed():
	return linear_velocity.length()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(!Engine.is_editor_hint()):
		_character_base.animate_sprite_by_vector(current_v, (speed() >= top_speed))
		var player_ref = get_tree().get_nodes_in_group("player")[0]
		
		#passive NPC
		if(ai_directive == alert_passive &&
		self.position.distance_to(player_ref.position) < talk_radius):	
			var vector_to_player = position.direction_to(player_ref.position)
			_character_base.face_to_vector(vector_to_player)
		
		#handle passive text printing
		if(has_passive_text):
			will_talk = self.position.distance_to(player_ref.position) < talk_radius
			if(!talking && will_talk):
				speech_instance = speech_bubble.instantiate()
				self.add_child(speech_instance)
				speech_instance.play_passive_text(passive_text, voice)
				talking = true
			else: if (!will_talk && talking && speech_instance.ready_to_disappear):
				speech_instance = self.get_node("speech_bubble")
				self.remove_child(speech_instance)
				talking = false
				
	#	#update speech bubble's presence
		if(has_monologue_text):
			if(!talking && will_talk && !showing_bubble):
				bubble_instance = can_talk_bubble.instantiate()
				self.add_child(bubble_instance)
				showing_bubble = true
			else: if (!will_talk && showing_bubble ||
						talking && showing_bubble):
				bubble_instance = self.get_node("can_talk_bubble")
				self.remove_child(bubble_instance)
				bubble_instance.queue_free()
				showing_bubble = false
				
			if(showing_bubble):
				bubble_instance.position = position

func _physics_process(delta):
	if(!Engine.is_editor_hint()):
		if(!immobilized):
			_character_base.face_to_vector(current_v)
			_character_base.animate_sprite_by_vector(current_v, (speed() >= top_speed))
		else:
			current_v = current_v * 0
		
		#apply velocity thru physics engine
		apply_force(current_v)
