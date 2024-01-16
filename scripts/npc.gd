extends RigidBody2D

@onready var _animated_sprite = $AnimatedSprite2D
@export var talk_radius = 100
@export var has_passive_text = false
@export var has_monologue_text = false

@export var passive_text = ""
@export var monologue_text = ""

var can_talk_bubble = preload("res://interface/can_talk_bubble.tscn")
var speech_bubble = preload("res://interface/speech_bubble.tscn")
var talking = false
var will_talk = false
var showing_bubble = false

var bubble_instance = null
var speech_instance = null

# Called when the node enters the scene tree for the first time.
func _ready():
	_animated_sprite.play("default")
	
func set_will_talk_false():
	will_talk = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player_ref = get_tree().get_nodes_in_group("player")[0]
	
	if(has_passive_text):
		will_talk = self.position.distance_to(player_ref.position) < talk_radius
		if(!talking && will_talk):
			speech_instance = speech_bubble.instantiate()
			self.add_child(speech_instance)
			speech_instance.play_passive_text(passive_text)
			talking = true
		else: if (!will_talk && talking):
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
			showing_bubble = false
			
		if(showing_bubble):
			bubble_instance.position = position
