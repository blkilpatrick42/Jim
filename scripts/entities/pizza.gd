extends Node2D

@onready var _prop = $pizza
@onready var _compass =$compass_arrow
@onready var _sprite = $pizza/sprite

var delivery_doors
var destination_door: Vector2

var random = RandomNumberGenerator.new()

var pizzas = 3
var delivery_points : Array[Vector2]

func destroy_self():
	if(_prop != null):
		_prop.queue_free()
	if(_compass != null ):
		_compass.queue_free()
	queue_free()

# Called when the node enters the scene tree for the first time.
func _ready():
	_compass.visible = false
	delivery_doors = get_tree().get_nodes_in_group("delivery_door")
	var iterator = 0
	while(iterator < pizzas):
		var delivery_door = delivery_doors[random.randi_range(0,delivery_doors.size()-1)]
		if(!delivery_points.has(delivery_door.global_position)):
			delivery_points.append(delivery_door.global_position)
			iterator += 1
	destination_door = get_closest_delivery_point()

func distance_to_destination_door() -> int:
	return _prop.global_position.distance_to(destination_door)

func distance_to_position(pos: Vector2):
	return _prop.global_position.distance_to(pos)

func get_closest_delivery_point() -> Vector2:
	var nearest_point = delivery_points[0]
	for delivery_point in delivery_points:
		var distance_to_nearest_point = distance_to_destination_door()
		var distance_to_other_point = distance_to_position(delivery_point)
		if(distance_to_other_point < distance_to_nearest_point):
			nearest_point = delivery_point
	return nearest_point

func get_closest_indoor_exit() -> Vector2:
	var exits = get_tree().get_nodes_in_group("indoor_exit")
	var nearest_exit = exits[0].global_position
	for exit in exits:
		var distance_to_nearest_exit = distance_to_position(nearest_exit)
		var distance_to_other_point = distance_to_position(exit.global_position)
		if(distance_to_other_point < distance_to_nearest_exit):
			nearest_exit = exit.global_position
	return nearest_exit

func update_pizza_stack():
	_sprite.play(str(pizzas))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(_prop != null):
		update_pizza_stack()
		if(_prop.is_picked_up() && _prop.get_parent().is_in_group("player")):
			_compass.visible = true
			_compass.global_position = _prop.global_position
			if(_prop.get_parent().get_parent().is_in_group("daylight_affected_ysort")):
				_compass.global_rotation = _prop.global_position.angle_to_point(destination_door)
			else:
				var exit = get_closest_indoor_exit()
				_compass.global_rotation = _prop.global_position.angle_to_point(exit)
		else:
			_compass.visible = false
			
			if(_prop.global_position.distance_to(destination_door) < 32):
				if(!_prop.is_picked_up()):
					pizzas -= 1
					if(pizzas > 0):
						delivery_points.erase(destination_door)
						destination_door = get_closest_delivery_point()
					else:
						destroy_self()
	else:
		destroy_self()
		
	
