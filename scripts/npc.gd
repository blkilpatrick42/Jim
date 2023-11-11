extends RigidBody2D

@onready var _animated_sprite = $AnimatedSprite2D

var can_talk_bubble = preload("res://interface/can_talk_bubble.tscn")
var talking = false
var will_talk = false
var showing_bubble = false

var bubble_instance = null

# Called when the node enters the scene tree for the first time.
func _ready():
	_animated_sprite.play("default")
	
	
func set_will_talk_false():
	will_talk = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	#update speech bubble's presence
	if(!talking && will_talk && !showing_bubble):
		bubble_instance = can_talk_bubble.instantiate()
		get_parent().add_child(bubble_instance)
		showing_bubble = true
	else: if (!will_talk && showing_bubble ||
				talking && showing_bubble):
		bubble_instance = get_tree().get_nodes_in_group("cantalkbubble")[0]
		get_parent().remove_child(bubble_instance)
		showing_bubble = false
		
	if(showing_bubble):
		bubble_instance.position = position
