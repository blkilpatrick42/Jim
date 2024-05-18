extends RigidBody2D

@onready var _sprite = $Sprite2D

var spark = preload("res://entities/effects/spark.tscn")

var speed = 185
var velocity = Vector2.RIGHT
@export var team = "red"

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity = Vector2.RIGHT.rotated(rotation) * speed
	self.add_to_group(team)
	match(team):
		"red":
			_sprite.modulate = Color(1,0,0)
		"blu":
			_sprite.modulate = Color(0,0,1)

func _on_body_entered(body:Node):
	var new_spark = spark.instantiate()
	get_parent().add_child(new_spark)
	new_spark.position = position
	new_spark.add_to_group(team)
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	linear_velocity = velocity
