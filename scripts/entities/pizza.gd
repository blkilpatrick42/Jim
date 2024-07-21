extends Node2D

@onready var _prop = $pizza
@onready var _compass =$compass_arrow
@onready var _pointer =$pointer_arrow
@onready var _sprite = $pizza/sprite

var quick_nohits = preload("res://dialog/dialog trees/delivery_trees/quick_nohits.tscn")
var quick_1hit = preload("res://dialog/dialog trees/delivery_trees/quick_1hits.tscn")
var quick_2hit = preload("res://dialog/dialog trees/delivery_trees/quick_2hits.tscn")
var normal_nohits = preload("res://dialog/dialog trees/delivery_trees/normal_nohits.tscn")
var normal_1hit = preload("res://dialog/dialog trees/delivery_trees/normal_1hit.tscn")
var normal_2hit = preload("res://dialog/dialog trees/delivery_trees/normal_2hit.tscn")
var slow_nohits = preload("res://dialog/dialog trees/delivery_trees/slow_nohits.tscn")
var slow_1hit = preload ("res://dialog/dialog trees/delivery_trees/slow_1hit.tscn")
var slow_2hit = preload("res://dialog/dialog trees/delivery_trees/slow_2hit.tscn")

var delivery_doors
var destination_door: Node

var current_guide_point : Vector2

var random = RandomNumberGenerator.new()

var hits = 0

var pizzas = 3
var selected_delivery_doors: Array[Node]

var switch_to_pointer_distance = 256

var timer : Timer = Timer.new()
var time_to_deliver_secs = 120

var dialog = preload("res://dialog/dialog.tscn")
var dialog_manager : Node
var delivery_dialog_tree : dialog_tree

var has_been_picked_up_before = false

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
	timer.one_shot = true
	add_child(timer)	
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
	var num_hits = hits
	if(num_hits > 3):
		num_hits = 3
	_sprite.play(str(pizzas,num_hits))

func _on_prop_collide():
	hits = hits + 1
	if(hits > 2):
		var player_ref = get_tree().get_nodes_in_group("player")[0]
		player_ref._on_pizza_lost()
	

func _on_picked_up():
	if(!has_been_picked_up_before):
		timer.start(time_to_deliver_secs)
		has_been_picked_up_before = true

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

func deliver_pizza():
	dialog_manager = dialog.instantiate()
	dialog_manager.set_speaker_node(destination_door)
	get_parent().add_child(dialog_manager)
	var player_ref = get_tree().get_nodes_in_group("player")[0]
	player_ref.enter_dialog()
	#slow
	if(timer.is_stopped()):
		if(hits == 0):
			delivery_dialog_tree = slow_nohits.instantiate()
		elif(hits == 1):
			delivery_dialog_tree = slow_1hit.instantiate()
		else:
			delivery_dialog_tree = slow_2hit.instantiate()
	#quick
	elif(timer.time_left > 60):
		if(hits == 0):
			delivery_dialog_tree = quick_nohits.instantiate()
		elif(hits == 1):
			delivery_dialog_tree = quick_1hit.instantiate()
		else:
			delivery_dialog_tree = quick_2hit.instantiate()
	#normal
	elif(timer.time_left < 60):
		if(hits == 0):
			delivery_dialog_tree = normal_nohits.instantiate()
		elif(hits == 1):
			delivery_dialog_tree = normal_1hit.instantiate()
		else:
			delivery_dialog_tree = normal_2hit.instantiate()
	
	dialog_manager.add_child(delivery_dialog_tree)
	dialog_manager.set_tree_and_start_dialog(delivery_dialog_tree)	
	pizzas -= 1
	if(pizzas > 0):
		selected_delivery_doors.erase(destination_door)
		destination_door = selected_delivery_doors[0]
	else:
		destroy_self()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(_prop != null):
		update_pizza_stack()
		if(_prop.is_picked_up() && 
		_prop.get_parent().is_in_group("player") && 
		!_prop.get_parent().dead):	
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
					deliver_pizza()
	else:
		destroy_self()
