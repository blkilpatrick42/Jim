extends Node2D

@onready var prop = $pizza
@onready var compass = $compass_arrow

var delivery_doors
var destination_door

var random = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	compass.visible = false
	delivery_doors = get_tree().get_nodes_in_group("delivery_door")
	destination_door = delivery_doors[random.randi_range(0,delivery_doors.size()-1)]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(prop.is_picked_up()):
		compass.visible = true
		compass.global_rotation = prop.global_position.angle_to_point (destination_door.global_position)
		compass.global_position = prop.global_position
	else:
		compass.visible = false
		
	if(prop.global_position.distance_to(destination_door.global_position) < 32):
		if(!prop.is_picked_up()):
			prop.queue_free()
			queue_free()
