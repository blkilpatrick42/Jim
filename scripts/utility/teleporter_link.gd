@tool
extends Node2D

@onready var _fade_to_black = $fade_to_black
@export var linked_teleporter:Node2D = null
@export var enter_x_push = 0
@export var enter_y_push = 0
@export var exit_x_push = 0
@export var exit_y_push = 0
@export var exit_only = false
@export var reparent_to_daylight = false
@export var reparent_to_no_daylight = false
@export var secs_for_control_back : int = 0

var entering = false
var exiting = false

var fade_alpha = 0.0
var fade_step = 0.05

var fade_step_secs = 0.05
var teleport_step_secs = 0.5
var timer_fade := Timer.new()
var timer_control_back := Timer.new()
var control_timer_active = false

var player_ref = null

var daylight_affected_ysort : Node
var no_daylight_ysort : Node

var npcs_using_teleporter : Array[Node] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	daylight_affected_ysort = get_tree().get_first_node_in_group("daylight_affected_ysort")
	no_daylight_ysort = get_tree().get_first_node_in_group("no_daylight_ysort")
	timer_fade.one_shot = true
	timer_control_back.one_shot = true
	add_child(timer_fade)
	add_child(timer_control_back)

func _draw():
	if(linked_teleporter != null && Engine.is_editor_hint()):
		draw_line(Vector2(), get_transform().affine_inverse() * linked_teleporter.global_position, Color(0,0,1,1), -1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_fade_to_black.global_position = Vector2(0,0)
	update_fade_alpha()
	if(Engine.is_editor_hint()):
		queue_redraw()
	if(entering):
		enter()
	else: if(exiting):
		exit()
	
	if(control_timer_active &&
		timer_control_back.is_stopped()):
			control_timer_active = false
			player_ref.set_control_frozen(false)

func enter():
	if(fade_alpha < 1 && timer_fade.is_stopped()):
		fade_alpha = fade_alpha + fade_step
		update_fade_alpha()
		timer_fade.start(fade_step_secs)
	else: if(fade_alpha >= 1):
		fade_alpha = 1
		update_fade_alpha()
		player_ref.global_position = linked_teleporter.global_position
		if(reparent_to_daylight):
			player_ref.reparent(daylight_affected_ysort)
		if(reparent_to_no_daylight):
			player_ref.reparent(no_daylight_ysort)
		linked_teleporter.player_ref = player_ref
		linked_teleporter.timer_fade.start(teleport_step_secs)
		linked_teleporter.exiting = true
		entering = false
		if(linked_teleporter.exit_x_push != 0):
				player_ref.set_current_v(Vector2(linked_teleporter.exit_x_push,0))
		if(linked_teleporter.exit_y_push != 0):
				player_ref.set_current_v(Vector2(0,linked_teleporter.exit_y_push))

func exit():
	if(fade_alpha > 0 && timer_fade.is_stopped()):
		fade_alpha = fade_alpha - fade_step
		update_fade_alpha()
		timer_fade.start(fade_step_secs)
	else: if(fade_alpha <= 0):
		fade_alpha = 0
		exiting = false
		player_ref.stop()
		if(secs_for_control_back > 0):
			control_timer_active = true
			timer_control_back.start(secs_for_control_back)
		else:
			player_ref.set_control_frozen(false)

func update_fade_alpha():
	_fade_to_black.color = Color(0,0,0,fade_alpha)
	if(linked_teleporter != null):
		linked_teleporter._fade_to_black.color = Color(0,0,0,fade_alpha)
		linked_teleporter.fade_alpha = fade_alpha


func _on_area_2d_body_exited(body):
	if(body in npcs_using_teleporter):
		npcs_using_teleporter.remove_at(npcs_using_teleporter.find(body))

func _on_area_2d_body_entered(body):
	if(body.is_in_group("player")):
		player_ref = body
		if(!entering && !exiting && !exit_only):
			entering = true
			player_ref.stop()
			player_ref.set_control_frozen(true)
			update_fade_alpha()
			timer_fade.start(fade_step_secs)
			if(enter_x_push != 0):
				player_ref.set_current_v(Vector2(enter_x_push,0))
			if(enter_y_push != 0):
				player_ref.set_current_v(Vector2(0,enter_y_push))
	elif(body.is_in_group("npc") && 
	npcs_using_teleporter.find(body) < 0 &&
	linked_teleporter.npcs_using_teleporter.find(body) < 0):	
		npcs_using_teleporter.append(body)
		body.global_position = linked_teleporter.global_position
		linked_teleporter.npcs_using_teleporter.append(body)
		if(reparent_to_daylight):
			body.reparent(daylight_affected_ysort)
		if(reparent_to_no_daylight):
			body.reparent(no_daylight_ysort)

