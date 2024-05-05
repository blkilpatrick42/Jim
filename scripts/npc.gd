extends RigidBody2D

#AI Directives
const full_passive = "full_passive"
const alert_passive = "alert_passive"

@onready var _animated_sprite = $AnimatedSprite2D
@export var talk_radius = 100
@export var has_passive_text = false
@export var has_monologue_text = false
@export var acknowledges_player = false
@export var facingPosition = "left"
@export var ai_directive = full_passive
@export var voice = "none"

@export var passive_text = ""
@export var monologue_text = ""

var can_talk_bubble = preload("res://interface/can_talk_bubble.tscn")
var speech_bubble = preload("res://interface/speech_bubble.tscn")
var talking = false
var will_talk = false
var showing_bubble = false
var is_walking = false

var sound_player := AudioStreamPlayer.new()

var bubble_instance = null
var speech_instance = null

# Called when the node enters the scene tree for the first time.
func _ready():
	_animated_sprite.play("default")
	add_child(sound_player)
	
func set_will_talk_false():
	will_talk = false
	

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

func stand():
	if(facingPosition == "left"):
		stand_left()
	else: if(facingPosition == "right"):
		stand_right()
	else: if(facingPosition == "down"):
		stand_down()
	else: if(facingPosition == "up"):
		stand_up()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player_ref = get_tree().get_nodes_in_group("player")[0]
	
	#passive NPC
	var cone_size = 32
	if(ai_directive == alert_passive &&
	self.position.distance_to(player_ref.position) < talk_radius):	
		if(player_ref.position.x < self.position.x + cone_size && 
		player_ref.position.x > self.position.x - cone_size && 
		player_ref.position.y < self.position.y):
			stand_up()
		else: if(player_ref.position.y < self.position.y + cone_size && 
		player_ref.position.y > self.position.y - cone_size && 
		player_ref.position.x > self.position.x):
			stand_right()
		else: if(player_ref.position.x < self.position.x + cone_size && 
		player_ref.position.x > self.position.x - cone_size && 
		player_ref.position.y > self.position.y):
			stand_down()	
		else: if(player_ref.position.y < self.position.y + cone_size && 
		player_ref.position.y > self.position.y - cone_size && 
		player_ref.position.x < self.position.x):
			stand_left()
	else:
		stand()
		
	
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
