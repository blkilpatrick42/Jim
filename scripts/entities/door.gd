extends Node2D

var sound_player := AudioStreamPlayer.new()
@onready var _animated_sprite = $AnimatedSprite2D
@onready var _collision_shape = $StaticBody2D/CollisionShape2D

@export var opens_for_groups: Array[String]
@export var locked_hours : Array[bool] #should either be empty or size = 24

@export var parent_door : Node2D

@export var locked = false

var time_keeper

var opened = false
var opening = false
var closing = false
var waiting_to_open = false
var waiting_to_close = false
var open_close_timer := Timer.new()
var open_close_time_secs = 0.5
var open_distance = 48

# Called when the node enters the scene tree for the first time.
func _ready():
	open_close_timer.one_shot = true
	add_child(open_close_timer)
	time_keeper = get_tree().get_first_node_in_group("time_keeper")

func open():
	if(!opened):
		_animated_sprite.play("open")
		opening = true

func get_parent_door():
	return parent_door

func close():
	if(opened):
		_animated_sprite.play("close")
		closing = true

func opener_is_near():
	var retVal = false
	for group in opens_for_groups:
		for obj in get_tree().get_nodes_in_group(group):
			if (global_position.distance_to(obj.global_position) <= open_distance):
				retVal = true
	return retVal

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#opener has to stand near the door for a period of time for it to open
	if(opened == false && !waiting_to_open && opener_is_near()):
		waiting_to_open = true
		open_close_timer.start((open_close_time_secs))
	
	#if that period of time has elapsed and the opener is still there, open
	if(!locked && open_close_timer.is_stopped() && waiting_to_open && opener_is_near()):
		open()
	else: if(open_close_timer.is_stopped() && waiting_to_open && !opener_is_near()):
		waiting_to_open = false
	
	#if the opener leaves the door and it is open, it will start a timer to close itself
	if(opened && !opener_is_near() && !waiting_to_close):
		waiting_to_close = true
		open_close_timer.start((open_close_time_secs))
	
	#if that period of time has elapsed and the opener is still gone, close
	if(open_close_timer.is_stopped() && waiting_to_close && !opener_is_near()):
		close()
	else: if(open_close_timer.is_stopped() && waiting_to_close && opener_is_near()):
		waiting_to_close = false
	
	#set lock by time using bool list locked_hours
	if(locked_hours.size() == 24):
		if(locked_hours[time_keeper.clock]):
			locked = true
		else: locked = false
	
	var last_frame_open = _animated_sprite.sprite_frames.get_frame_count("open")-1 
	var last_frame_close = _animated_sprite.sprite_frames.get_frame_count("close")-1 
	if(opening && _animated_sprite.frame == last_frame_open):
		opened = true
		opening = false
		_animated_sprite.play(("opened"))
		_collision_shape.set_deferred("disabled", true)
	else: if(closing && _animated_sprite.frame == last_frame_close):
		opened = false
		closing = false
		_animated_sprite.play(("closed"))
		_collision_shape.set_deferred("disabled", false)
