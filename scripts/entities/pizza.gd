extends Node2D

@onready var _prop = $pizza
@onready var _compass =$compass_arrow
@onready var _pointer =$pointer_arrow
@onready var _sprite = $pizza/sprite

var delivery_doors
var destination_door: Node

var current_guide_point : Vector2

var random = RandomNumberGenerator.new()

var hits = 0

var pizzas = 3
var selected_delivery_doors: Array[Node]

var switch_to_pointer_distance = 256

func destroy_self():
	if(_prop != null):
		_prop.queue_free()
	if(_compass != null):
		_compass.queue_free()
	if (_pointer != null):
		_pointer.queue_free()
	queue_free()

# Called when the node enters the scene tree for the first time.
func _ready():
	_compass.visible = false
	_pointer.visible = false
	delivery_doors = get_tree().get_nodes_in_group("delivery_door")
	var iterator = 0
	while(iterator < pizzas):
		var random_index = random.randi_range(0,delivery_doors.size()-1)
		var delivery_door = delivery_doors[random_index]
		delivery_doors.remove_at(random_index)
		selected_delivery_doors.append(delivery_door)
		iterator += 1
	destination_door = selected_delivery_doors[0]

func distance_to_position(pos: Vector2):
	return _prop.global_position.distance_to(pos)

func get_closest_delivery_point() -> Node:
	var nearest_door = delivery_doors[0]
	for delivery_door in selected_delivery_doors:
		var distance_to_nearest_door = distance_to_position(nearest_door.global_position)
		var distance_to_other_door = distance_to_position(delivery_door.global_position)
		if(distance_to_other_door < distance_to_nearest_door):
			nearest_door = delivery_door
	return nearest_door

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

func _on_prop_collide():
	hits = hits + 1

func update_compass_pointer():
	_compass.global_position = _prop.global_position
	if(distance_to_position(current_guide_point) < switch_to_pointer_distance):
		_compass.visible = false
		_pointer.global_position = current_guide_point
		_pointer.visible = true
	else:
		_pointer.visible = false
		_compass.visible = true
		_compass.global_rotation = _prop.global_position.angle_to_point(current_guide_point)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(_prop != null):
		update_pizza_stack()
		if(_prop.is_picked_up() && 
		_prop.get_parent().is_in_group("player") && 
		!_prop.get_parent().dead):	
			#if we're close enough, turn on the pointer arrow and turn off the compass
			if(distance_to_position(destination_door.global_position) < switch_to_pointer_distance):
				current_guide_point = destination_door.global_position
			else:
				#if outdoors, point to parent door. 
				if(_prop.get_parent().get_parent().is_in_group("daylight_affected_ysort")):
					var outer_door = destination_door.get_parent_door()
					current_guide_point = outer_door.global_position
				else:
					var exit = get_closest_indoor_exit()
					current_guide_point = exit
			update_compass_pointer()
		else:
			_compass.visible = false
			if(_prop.global_position.distance_to(destination_door.global_position) < 32):
				if(!_prop.is_picked_up()):
					pizzas -= 1
					if(pizzas > 0):
						selected_delivery_doors.erase(destination_door)
						destination_door = selected_delivery_doors[0]
					else:
						destroy_self()
	else:
		destroy_self()
