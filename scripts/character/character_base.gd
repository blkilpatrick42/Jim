@tool
extends Node2D
@onready var _base_sprite = $base_sprite
@onready var _hat = $hat
@onready var _top = $top
@onready var _bottom = $bottom
@export var base_spriteframes : SpriteFrames = null
@export var hat_spriteframes : SpriteFrames = null
@export var top_spriteframes : SpriteFrames = null
@export var bottom_spriteframes : SpriteFrames = null

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

func set_facing_dir(facingDir):
	facing_dir = facingDir

func play_animation(animation: String):
	if(_base_sprite.sprite_frames != null):
		_base_sprite.play(animation)
	if(_hat.sprite_frames != null):
		_hat.play(animation)
	if(_top.sprite_frames != null):
		_top.play(animation)
	if(_bottom.sprite_frames != null):
		_bottom.play(animation)

func set_speed_scales(scale):
	if(_base_sprite.sprite_frames != null):
		_base_sprite.set_speed_scale(scale)
	if(_hat.sprite_frames != null):
		_hat.set_speed_scale(scale)
	if(_top.sprite_frames != null):
		_top.set_speed_scale(scale)
	if(_bottom.sprite_frames != null):
		_bottom.set_speed_scale(scale)

func stand_dir(direction):
	play_animation(str("stand_",direction))

func walk_dir(direction):
	play_animation(str("walk_",direction))

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
		set_speed_scales(animationScale)
	else:
		set_speed_scales(1)

func set_spriteframes(base, hat, top, bottom):
	if(_base_sprite != null):
		_base_sprite.sprite_frames = base
	if(_hat != null):
		_hat.sprite_frames = hat
	if(_top != null):
		_top.sprite_frames = top
	if(_bottom != null):
		_bottom.sprite_frames = bottom

	if(Engine.is_editor_hint()):
		queue_redraw()

# Called when the node enters the scene tree for the first time.
func _ready():
	set_spriteframes(base_spriteframes,
	hat_spriteframes,
	top_spriteframes,
	bottom_spriteframes)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
