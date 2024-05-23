extends Node2D
@onready var _base_sprite = $base_sprite

#current facing direction
@export var facing_dir = "left"

#const strings representing the four cardinal directiosn a character can face
const facing_dir_right = "right"
const facing_dir_left = "left"
const facing_dir_up = "up"
const facing_dir_down = "down"

func get_facing_dir():
	return facing_dir

func face_up():
	facing_dir = facing_dir_up

func face_down():
	facing_dir = facing_dir_down
	
func face_left():
	facing_dir = facing_dir_left

func face_right():
	facing_dir = facing_dir_right

func stand_dir(direction):
	_base_sprite.play(str("stand_",facing_dir))

func walk_dir(direction):
	_base_sprite.play(str("walk_",facing_dir))

#animate sprite based on velocity
func set_sprite_by_vector(in_vector :Vector2, walk_override := false):
	if(in_vector.length() > 0 || walk_override):
		walk_dir(facing_dir)
	else: 
		stand_dir(facing_dir)

func set_animation_scale(scalar, top):
	#scale animation to movement speed
	if(scalar != 0):
		#Base speed of 20%. We ramp to 100% (full speed) using a ratio of 
		#speed/topspeed for the remaining 80%.	
		var baseScale = 0.2
		var velocityScale = scalar / top
		var remainderScale = 0.8 * velocityScale
		var animationScale = baseScale + remainderScale
		_base_sprite.set_speed_scale(animationScale)
	else:
		_base_sprite.set_speed_scale(1)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
