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

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_physics_pos(vector2):
	should_reset = true
	new_position = vector2

func pick_up():
	if(will_pickup):
		#teleport WAY out of bounds so that we don't
		#end up with an invisible prop messing with
		#physics stuff
		set_physics_pos(Vector2(-1000100, -1000100)) 
		_collision_shape.set_deferred("disabled", true)
		picked_up = true
		will_pickup = false

func put_down():
	if(picked_up):
		picked_up = false
		_collision_shape.set_deferred("disabled", false)
		var playerRef = get_tree().get_nodes_in_group("player")[0]
		set_physics_pos(playerRef.position + Vector2(0, 50))
	
func set_will_pickup_false():
	will_pickup = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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


