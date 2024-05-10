@tool
extends Node2D

@export var next_point = Node2D
@export var has_next_point = false
@export var prev_point = Node2D
@export var has_prev_point = false

# Called when the node enters the scene tree for the first time.
func _ready():
	queue_redraw()

func _draw():
	if Engine.is_editor_hint():
		if(has_next_point):
			draw_line(Vector2(), get_transform().affine_inverse() * next_point.position, Color(1,0,0,1), -1)
		if(has_prev_point):
			draw_line(Vector2(), get_transform().affine_inverse() * prev_point.position, Color(0,0,1,1), -1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()
