extends Node2D

var sound_player := AudioStreamPlayer.new()
@onready var _animated_sprite = $AnimatedSprite2D
@onready var _collision_shape = $StaticBody2D/CollisionShape2D

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

func open():
	if(!opened):
		_animated_sprite.play("open")
		opening = true

func close():
	if(opened):
		_animated_sprite.play("close")
		closing = true

func player_is_close():
	var player_ref = get_tree().get_first_node_in_group("player")
	if (position.distance_to(player_ref.position) <= open_distance):
		return true
	else:
		return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#player has to stand near the door for a period of time for it to open
	if(opened == false && !waiting_to_open && player_is_close()):
		waiting_to_open = true
		open_close_timer.start((open_close_time_secs))
	
	#if that period of time has elapsed and the player is still there, open
	if(open_close_timer.is_stopped() && waiting_to_open && player_is_close()):
		open()
	else: if(open_close_timer.is_stopped() && waiting_to_open && !player_is_close()):
		waiting_to_open = false
	
	#if the player leaves the door and it is open, it will start a timer to close itself
	if(opened && !player_is_close() && !waiting_to_close):
		waiting_to_close = true
		open_close_timer.start((open_close_time_secs))
	
	#if that period of time has elapsed and the player is still gone, close
	if(open_close_timer.is_stopped() && waiting_to_close && !player_is_close()):
		close()
	else: if(open_close_timer.is_stopped() && waiting_to_close && player_is_close()):
		waiting_to_close = false
	
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
