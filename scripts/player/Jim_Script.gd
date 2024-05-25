@tool
extends RigidBody2D

@onready var _character_base = $character_base
@onready var _grabber = $grabber
@onready var _tough_luck = $tough_luck

@export var base_spriteframes : SpriteFrames
@export var hat_spriteframes : SpriteFrames
@export var top_spriteframes : SpriteFrames
@export var bottom_spriteframes : SpriteFrames
@export var facing_dir = "right"

#TODO: get this working with character composition (will be an absolute bastard wah)
var player_die = preload("res://entities/player/player_die.tscn") 
var dash_get = preload("res://interface/dash_get.tscn")
var die_material = preload("res://entities/player/die_material.tres")

var sound_player := AudioStreamPlayer.new()

var normal_speed = 50000
var dash_speed = 250000
var acceleration_quotient = normal_speed
var top_speed = 180

var can_dash = true
var is_dashing = false
var dash_time_secs = 0.5
var dash_regen_time_secs = 5
var timer_dash := Timer.new()
var timer_dash_regen := Timer.new()

var holding_object = false
var will_grab_object = null
var will_talk_npc = null
var grabbed_object = null
var control_frozen = false
var current_v = Vector2(0,0)

var dead = false

func _ready():
	timer_dash.one_shot = true
	timer_dash_regen.one_shot = true
	add_child(sound_player)
	add_child(timer_dash)
	add_child(timer_dash_regen)
	sound_player.volume_db = -12
	
	#set up character base
	_character_base.set_facing_dir(facing_dir)
	_character_base.set_spriteframes(base_spriteframes,
	hat_spriteframes,
	top_spriteframes,
	bottom_spriteframes)
	
	if(Engine.is_editor_hint()):
		queue_redraw()

func get_input():
	if(!control_frozen):
		#orient and player according to input
		if Input.is_action_pressed("right"):
			_character_base.face_right()
		else: if Input.is_action_pressed("left"):
			_character_base.face_left()
		else: if Input.is_action_pressed("up"):
			_character_base.face_up()
		else: if Input.is_action_pressed("down"):
			_character_base.face_down()
		handle_pickup()
		handle_throw()
		handle_dash()
		move_jim()

func _on_body_entered(body:Node):
	if(body.is_in_group("bullet")):
		die()

func die():
	if(!dead):
		var die_guy = player_die.instantiate()
		_character_base.reparent(die_guy)
		die_guy.position = position
		_character_base.global_position = die_guy.global_position
		_character_base.set_all_materials(die_material)
		get_parent().add_child(die_guy)
		visible = false
		die_guy.start_dyin(_character_base.get_facing_dir())
		dead = true

func handle_pickup():
	if Input.is_action_just_pressed("pickup"):
			pick_up()

func handle_dash():
	if Input.is_action_just_pressed("dash"):
			dash()

func handle_throw():
	if Input.is_action_just_pressed("throw"):
			throw()

func set_control_frozen(value):
	control_frozen = value

func set_current_v(vect : Vector2):
	current_v = vect

func stop():
	current_v = Vector2(0,0)

func throw():
	if(holding_object):
		sound_player.stream = load("res://audio/soundFX/woosh.wav")
		sound_player.play()
		grabbed_object.throw(_character_base.get_facing_dir())
		grabbed_object = null
		holding_object = false

func pick_up():
	if(will_grab_object != null && !holding_object):
		sound_player.stream = load("res://audio/soundFX/pickup.wav")
		sound_player.play()
		will_grab_object.pick_up()
		grabbed_object = will_grab_object
		holding_object = true
	else: if(holding_object):
		sound_player.stream = load("res://audio/soundFX/putdown.wav")
		sound_player.play()
		grabbed_object.put_down(_character_base.get_facing_dir())
		grabbed_object = null
		holding_object = false

func dash():
	if(!is_dashing && Input.get_vector("left", "right", "up", "down").length() > 0):
		if(can_dash):
			sound_player.stream = load("res://audio/soundFX/woosh.wav")
			sound_player.play()
			is_dashing = true
			can_dash = false
			timer_dash.start(dash_time_secs)

func speed():
	return linear_velocity.length()

func update_grabber():
	match(_character_base.get_facing_dir()):
		_character_base.facing_dir_right:
			_grabber.set_rotation_degrees(270) 
		_character_base.facing_dir_left:
			_grabber.set_rotation_degrees(90)
		_character_base.facing_dir_up:
			_grabber.set_rotation_degrees(180)
		_character_base.facing_dir_down:
			_grabber.set_rotation_degrees(0)

func move_jim():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	
	#accelerate if we have't hit max
	if(input_direction.length() != 0 && speed() < top_speed):
		current_v = input_direction * acceleration_quotient 
	else: 
		current_v = input_direction * 0
	
	_character_base.set_animation_scale(0.2, 0.8, speed(), top_speed)

func _process(_delta):
	if(!Engine.is_editor_hint()):
		if(!dead):
			_character_base.animate_sprite_by_vector(current_v, (speed() >= top_speed))
			update_grabber()
			will_grab_object = null
			if(!holding_object):
				var grabObj = null
				
				if(_grabber.is_colliding()):
					grabObj = _grabber.get_collider(0)
				
				#check for pickupables
				get_tree().call_group("pickupable", "set_will_pickup_false")
				if(grabObj != null && 
				grabObj.is_in_group("pickupable")):
					grabObj.will_pickup = true
					will_grab_object = grabObj
			
			#stop dash if timer has been esceeded
			if(is_dashing):
				acceleration_quotient = dash_speed
				if(timer_dash.is_stopped()):
					is_dashing = false
					acceleration_quotient = normal_speed
					timer_dash_regen.start(dash_regen_time_secs)
			else:
				acceleration_quotient = normal_speed
			
			#regen dash
			if(timer_dash_regen.is_stopped() && can_dash == false && !is_dashing):
				sound_player.stream = load("res://audio/soundFX/dashget.wav")
				sound_player.play()
				can_dash = true
				add_child(dash_get.instantiate())

func _physics_process(delta):
	if(!Engine.is_editor_hint()):
		if(!dead):
			get_input()
			apply_force(current_v)
		



