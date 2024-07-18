@tool
extends RigidBody2D

@onready var _character_base = $character_base
@onready var _grabber = $grabber
@onready var _tough_luck = $tough_luck
@onready var _collision = $CollisionShape2D
@onready var _ui = $ui_canvas/player_ui
@onready var _camera = $Camera2D

@export var base_spriteframes : SpriteFrames
@export var hat_spriteframes : SpriteFrames
@export var top_spriteframes : SpriteFrames
@export var bottom_spriteframes : SpriteFrames
@export var facing_dir = "right"

@export var no_clip = false

var player_die = preload("res://entities/characters/player/player_die.tscn") 
var dash_get = preload("res://interface/dash_get.tscn")
var die_material = preload("res://entities/characters/player/die_material.tres")
var speech_bubble = preload("res://dialog/speech_bubble.tscn")

var sound_player := AudioStreamPlayer.new()

const normal_speed = 50000
const dash_speed = 250000
var acceleration_quotient = normal_speed
const top_speed = 180

var can_dash = true
var is_dashing = false
var dash_time_secs = 0.5
var dash_regen_time_secs = 5
var timer_dash := Timer.new()
var timer_dash_regen := Timer.new()

var in_dialog = false
var dialog_panning = false

var holding_object = false
var will_grab_object = null
var grabbed_object = null
var control_frozen = false
var current_v = Vector2(0,0)

const max_hp = 3
var current_hp = 3
var is_invincible = false
var invincibility_timer := Timer.new()
var damage_collision_layer = 13

var dead = false

const pan_x_max = 96
const pan_y_max = 96
var pan_timer := Timer.new()
var pan_step = 4
const pan_step_time_secs = 0.005
var camera_offset = Vector2(0,0)

var speech_instance = null
var comment_timer := Timer.new()
var comment_timer_wait_secs = 1
var comment_waiting = false

var money : int = 0

func _ready():
	_collision.disabled = no_clip
	timer_dash.one_shot = true
	timer_dash_regen.one_shot = true
	invincibility_timer.one_shot = true
	pan_timer.one_shot = true
	comment_timer.one_shot = true
	sound_player.bus = "Effects"
	add_child(sound_player)
	add_child(timer_dash)
	add_child(timer_dash_regen)
	add_child(invincibility_timer)
	add_child(comment_timer)
	add_child(pan_timer)
	
	#set up character base
	_character_base.set_facing_dir(facing_dir)
	_character_base.set_spriteframes(base_spriteframes,
	hat_spriteframes,
	top_spriteframes,
	bottom_spriteframes)
	
	pan_timer.start(pan_step_time_secs)
	
	if(Engine.is_editor_hint()):
		queue_redraw()

func enter_dialog():
	in_dialog = true
	control_frozen = true
	dialog_panning = true
	
func exit_dialog():
	in_dialog = false
	control_frozen = false
	dialog_panning = false

func get_money():
	return money

func _on_add_money(num : int):
	set_money(money + num)

func set_money(num : int):
	money = num
	_ui.set_money(money)

func go_invincible():
	invincibility_timer.start(1.5)
	_character_base.start_flashing()
	is_invincible = true
	set_collision_layer_value(damage_collision_layer,false)

func go_vincible():
	_character_base.stop_flashing()
	is_invincible = false
	set_collision_layer_value(damage_collision_layer,true)

func _activate_location_header(name : String):
	_ui.activate_header(name)

func get_input():
	if(!control_frozen):
		#orient and player according to input
		if Input.is_action_pressed(direction.right):
			_character_base.face_right()
		else: if Input.is_action_pressed(direction.left):
			_character_base.face_left()
		else: if Input.is_action_pressed(direction.up):
			_character_base.face_up()
		else: if Input.is_action_pressed(direction.down):
			_character_base.face_down()
		handle_interact()
		handle_throw()
		handle_dash()
		handle_camera_pan()
		move()

func get_current_hp():
	return current_hp

func increment_hp():
	if(current_hp < max_hp):
		current_hp = current_hp + 1
		_ui.update_hearts(current_hp)

func reduce_hp():
	current_hp = current_hp - 1
	_ui.update_hearts(current_hp)
	if(current_hp == 0):
		die()
	else:
		go_invincible()

func _on_body_entered(body:Node):
	if(body.is_in_group("bullet")):
		reduce_hp()

func _on_make_comment(text : String):
	if(speech_instance != null):
		speech_instance.queue_free()
	speech_instance = speech_bubble.instantiate()
	self.add_child(speech_instance)
	speech_instance.play_passive_text(text, "sine_voice")
	comment_timer.start(comment_timer_wait_secs)
	comment_waiting = false

func handle_camera_pan():
	var pan_direction = Input.get_vector("pan_left", "pan_right", "pan_up", "pan_down")
	if(dialog_panning):
		pan_direction = Vector2(0,-1)
	
	#add dead zone for joysticks
	if(pan_direction.x < 0.4 && pan_direction.x > -0.4):
		pan_direction.x = 0
	if(pan_direction.y < 0.4 && pan_direction.y > -0.4):
		pan_direction.y = 0
	
	if(pan_timer.is_stopped()):
		var destination_x = (pan_direction.x/abs(pan_direction.x)) * pan_x_max 
		var destination_y = (pan_direction.y/abs(pan_direction.y)) * pan_y_max
		#var max_vector = Vector2(pan_x_max,pan_y_max)
		
		var adj_x_step = pan_step
		var adj_y_step = pan_step
		var divisor = 3
		var x_edge = pan_x_max / divisor
		var y_edge = pan_x_max / divisor
		var edge_x_distance = pan_x_max - abs(camera_offset.x)
		var edge_y_distance = pan_y_max - abs(camera_offset.y)
		
		if(edge_x_distance < x_edge):
			adj_x_step = (abs(edge_x_distance)/x_edge) * pan_step
		if(edge_y_distance < y_edge):
			adj_y_step = (abs(edge_y_distance)/y_edge) * pan_step
			
		var ret_adj_x_step = pan_step
		var ret_adj_y_step = pan_step
		if(abs(camera_offset.x) < x_edge):
			ret_adj_x_step = ceil((abs(camera_offset.x)/x_edge) * pan_step)
		if(abs(camera_offset.y) < y_edge):
			ret_adj_y_step = ceil((abs(camera_offset.y)/y_edge) * pan_step)
		
		#pan x
		if(destination_x > 0):
			if(camera_offset.x < destination_x):
				camera_offset = camera_offset + Vector2(adj_x_step,0)
		elif(destination_x < 0):
			if(camera_offset.x > destination_x):
				camera_offset = camera_offset + Vector2(-adj_x_step,0)
		
		#return x to center
		if(pan_direction.x == 0):
			if(camera_offset.x > 0):
				camera_offset = camera_offset + Vector2(-ret_adj_x_step,0)
			elif(camera_offset.x < 0):
				camera_offset = camera_offset + Vector2(ret_adj_x_step,0)
			
		#pan y
		if(destination_y > 0):
			if(camera_offset.y < destination_y):
				camera_offset = camera_offset + Vector2(0,adj_y_step)
		elif(destination_y < 0):
			if(camera_offset.y > destination_y):
				camera_offset = camera_offset + Vector2(0,-adj_y_step)
			
		#return y to center
		if(pan_direction.y == 0):
			if(camera_offset.y > 0):
				camera_offset = camera_offset + Vector2(0,-ret_adj_y_step)
			elif(camera_offset.y < 0):
				camera_offset = camera_offset + Vector2(0,ret_adj_y_step)
		
			#snap to center
		if(pan_direction.x == 0 &&
		camera_offset.x < 1 && 
		camera_offset.x > -1):
			camera_offset.x = 0
		if(pan_direction.y == 0 &&
		camera_offset.y < 1 && 
		camera_offset.y > -1):
			camera_offset.y = 0
		
		pan_timer.start(pan_step_time_secs)
	
	_camera.set_offset(camera_offset)

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

func handle_interact():
	if Input.is_action_just_pressed("interact"):
			if(_grabber.is_colliding()):
					var grabObj = _grabber.get_collider(0)
					if(grabObj.is_in_group("interactable")):
						grabObj.interact()
			handle_pick_up()

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

func set_holding_object(is_holding):
	holding_object = is_holding
	_character_base.set_arms_raised(is_holding)
		

func throw():
	if(holding_object):
		sound_player.stream = load("res://audio/soundFX/woosh.wav")
		sound_player.play()
		grabbed_object.throw(_character_base.get_facing_dir())
		grabbed_object = null
		set_holding_object(false)

func handle_pick_up():
	if(will_grab_object != null && !holding_object):
		sound_player.stream = load("res://audio/soundFX/pickup.wav")
		sound_player.play()
		will_grab_object.pick_up(self)
		grabbed_object = will_grab_object
		set_holding_object(true)
	else: if(holding_object):
		sound_player.stream = load("res://audio/soundFX/putdown.wav")
		sound_player.play()
		grabbed_object.put_down(_character_base.get_facing_dir())
		grabbed_object = null
		set_holding_object(false)

func dash():
	if(!is_dashing && Input.get_vector(direction.left, direction.right, direction.up, direction.down).length() > 0):
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
		direction.right:
			_grabber.set_rotation_degrees(270) 
		direction.left:
			_grabber.set_rotation_degrees(90)
		direction.up:
			_grabber.set_rotation_degrees(180)
		direction.down:
			_grabber.set_rotation_degrees(0)

func move():
	var input_direction = Input.get_vector(direction.left, direction.right, direction.up, direction.down)
	
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
			#check grabber for pick-upable objects
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
			
			if(speech_instance != null &&
			speech_instance.full_text_displayed):
				if(!comment_waiting):
					comment_timer.start(comment_timer_wait_secs)
					comment_waiting = true
				else:
					if(comment_timer.is_stopped()):
						speech_instance.queue_free()
					
func _physics_process(delta):
	if(!Engine.is_editor_hint()):
		if(!dead):
			get_input()
			if(dialog_panning):
				handle_camera_pan()
			apply_force(current_v)
			if(invincibility_timer.is_stopped() &&
			is_invincible == true):
				go_vincible()
			_ui.update_hearts(current_hp)
			_ui.set_money(money)
		
