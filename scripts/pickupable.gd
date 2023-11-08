extends RigidBody2D

@onready var _collision_shape = $CollisionShape2D
@onready var sprite = $sprite

var picked_up = false
@export var will_pickup = false
var showing_arrow = false
var distance_for_pickup = 300
var pickup_arrow = preload("res://interface/pickup_arrow.tscn")
var arrow_instance = null 

var should_reset = false
var new_position = Vector2(0, 0)
var should_unhide = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func pick_up():
	if(will_pickup):
		picked_up = true
		_collision_shape.disabled = true

func put_down():
	if(picked_up):
		sprite.hide()
		picked_up = false
		var playerRef = get_tree().get_nodes_in_group("player")[0]
		new_position = playerRef.position + Vector2(0, 50)
		_collision_shape.disabled = false
		should_reset = true
		should_unhide = 2
	
func set_will_pickup_false():
	will_pickup = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(should_unhide == 0):
		sprite.show()
	else:
		should_unhide = should_unhide - 1
		
#	#update pickup arrow's presence
	if(!picked_up && will_pickup && !showing_arrow):
		arrow_instance = pickup_arrow.instantiate()
		get_parent().add_child(arrow_instance)
		showing_arrow = true
	else: if (!will_pickup && showing_arrow ||
				picked_up && showing_arrow):
		arrow_instance = get_tree().get_nodes_in_group("pickuparrow")[0]
		get_parent().remove_child(arrow_instance)
		showing_arrow = false
		
	if(showing_arrow):
		arrow_instance.position = position
		
	if(picked_up):
		var playerRef = get_tree().get_nodes_in_group("player")[0]
		position = (playerRef.position + Vector2(0, -50))

func _integrate_forces(state):
	if should_reset:
		should_reset = false
		state.transform.origin = new_position


