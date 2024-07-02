extends RigidBody2D

@onready var _sprite = $Sprite2D
var sound_player := AudioStreamPlayer2D.new()

var spark = preload("res://effects/bullet_spark.tscn")

var speed = 185
var velocity = Vector2.RIGHT
var source_obj :Node
@export var team = "red"

# Called when the node enters the scene tree for the first time.
func _ready():
	sound_player.max_distance = 500
	#sound_player.attenuation = 2
	add_child(sound_player)
	self.add_to_group(team)
	match(team):
		"red":
			_sprite.modulate = Color(1,0,0)
		"blu":
			_sprite.modulate = Color(0,0,1)

func _on_body_entered(body:Node):
	create_spark_deadly()
	queue_free()

func set_source_obj(obj:Node):
	source_obj = obj

#simulate muzzle flash, essentially
func create_spark_benign():
	sound_player.stream = load("res://audio/soundFX/bigCollide.wav")
	sound_player.play()
	var new_spark = spark.instantiate()
	new_spark.remove_from_group("spark")
	get_parent().call_deferred("add_child", new_spark)
	new_spark.position = position

func create_spark_deadly():
	sound_player.stream = load("res://audio/soundFX/bigCollide.wav")
	sound_player.play()
	var new_spark = spark.instantiate()
	get_parent().call_deferred("add_child", new_spark)
	new_spark.position = position
	new_spark.add_to_group(team)
	new_spark.set_source_obj(source_obj)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func apply_velocity():
	velocity = Vector2.RIGHT.rotated(rotation) * speed

func _physics_process(delta):
	linear_velocity = velocity
