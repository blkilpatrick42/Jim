extends RigidBody2D

@onready var _collision_shape = $CollisionShape2D
@onready var sprite = $sprite

@export var force_factor = 100

var picked_up = false
var will_pickup = false
var showing_arrow = false
var distance_for_pickup = 100
var pickup_arrow = preload("res://interface/pickup_arrow.tscn")
var spark = preload("res://entities/effects/spark.tscn")
var arrow_instance = null 

var sound_player := AudioStreamPlayer2D.new()

var should_reset = false
var new_position = Vector2(0, 0)

var throw_force = Vector2(0, 0)
var thrown = false

var player_y_offset = 24

@export var spark_time_secs = 200 #time after being thrown in which a spark is created on collide
var timer_spark := Timer.new()
var can_spark = false

var local_collision_pos = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	timer_spark.one_shot = true
	add_child(timer_spark)
	sound_player.max_distance = 500
	sound_player.attenuation = 2
	add_child(sound_player)
	sound_player.volume_db = -20

func set_physics_pos(vector2):
	should_reset = true
	new_position = vector2

func throw(direction):
	if(picked_up):
		thrown = true
		picked_up = false
		_collision_shape.set_deferred("disabled", false)
		var playerRef = get_tree().get_nodes_in_group("player")[0]
		timer_spark.start(spark_time_secs)
		can_spark = true
		match(direction):
			"left":
				throw_force = Vector2(-force_factor,0)
				set_physics_pos(playerRef.position + Vector2(0, -player_y_offset))
			"right":
				throw_force = Vector2(force_factor,0)
				set_physics_pos(playerRef.position + Vector2(0, -player_y_offset))
			"up":
				throw_force = Vector2(0,-force_factor)
				set_physics_pos(playerRef.position + Vector2(0, -player_y_offset))
			"down":
				throw_force = Vector2(0,force_factor)
				set_physics_pos(playerRef.position + Vector2(0, player_y_offset))
#
#func _on_body_entered(body:Node):
#	if(linear_velocity.length() > spark_velocity):
#		var nSpark = spark.instantiate()
#		get_parent().add_child(nSpark)
#		nSpark.position = local_collision_pos
#		sound_player.stream = load("res://audio/soundFX/bigCollide.wav")
#		sound_player.play()
#	else:
#		sound_player.stream = load("res://audio/soundFX/smallCollide.wav")
#		sound_player.play()

func pick_up():
	if(will_pickup):
		#teleport WAY out of bounds so that we don't
		#end up with an invisible prop messing with
		#physics stuff
		set_physics_pos(Vector2(-1000100, -1000100)) 
		_collision_shape.set_deferred("disabled", true)
		picked_up = true
		will_pickup = false

func put_down(direction):
	if(picked_up):
		picked_up = false
		_collision_shape.set_deferred("disabled", false)
		var playerRef = get_tree().get_nodes_in_group("player")[0]
		match(direction):
			"left":
				throw_force = Vector2(-force_factor,0)
				set_physics_pos(playerRef.position + Vector2(-player_y_offset, 0))
			"right":
				throw_force = Vector2(force_factor,0)
				set_physics_pos(playerRef.position + Vector2(player_y_offset, 0))
			"up":
				throw_force = Vector2(0,-force_factor)
				set_physics_pos(playerRef.position + Vector2(0, -player_y_offset))
			"down":
				throw_force = Vector2(0,force_factor)
				set_physics_pos(playerRef.position + Vector2(0, player_y_offset))
			
		
	
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
		arrow_instance.queue_free()
		showing_arrow = false
		
	if(showing_arrow):
		arrow_instance.position = position
		
	if(picked_up):
		var playerRef = get_tree().get_nodes_in_group("player")[0]
		position = (playerRef.position + Vector2(0, -player_y_offset))
		

#func _physics_process(delta):
#	if(linear_velocity.length() > spark_velocity):
#		set_collision_mask_value(1,false)
#		set_collision_mask_value(3,true)
#		set_collision_layer_value(1,false)
#		set_collision_layer_value(3,true)
#	else:
#		set_collision_mask_value(1,true)
#		set_collision_mask_value(3,false)
#		set_collision_layer_value(1,true)
#		set_collision_layer_value(3,false)

func _integrate_forces(state):
	if(state.get_contact_count() >= 1):  #this check is needed or it will throw errors 
		local_collision_pos = state.get_contact_local_position(0)
		if(!timer_spark.is_stopped() && can_spark):
			can_spark = false
			var nSpark = spark.instantiate()
			get_parent().add_child(nSpark)
			nSpark.position = local_collision_pos
			sound_player.stream = load("res://audio/soundFX/bigCollide.wav")
			sound_player.play()
		else:
			sound_player.stream = load("res://audio/soundFX/smallCollide.wav")
			sound_player.play()
		
	if should_reset:
		should_reset = false
		state.transform.origin = new_position
	if thrown:
		state.apply_central_impulse(throw_force)
		thrown = false

#func _physics_process(delta):


