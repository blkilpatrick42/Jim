@tool
extends Node2D

@export var next_points : Array[Node] = []
@export var prev_point = Node2D
@export var has_prev_point = false

var random = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func has_next_point():
	return next_points.size() > 0

func get_next_point():
	if(has_next_point()):
		return next_points[randi_range(0, next_points.size() - 1)]
	else:
		return prev_point

func is_occupied():
	var mobsters = get_tree().get_nodes_in_group("mobster")
	for mob in mobsters:
		if(position.distance_to(mob.position) < mob.nav_target_reached):
			return true
	return false

func _draw():
	if(Engine.is_editor_hint()):
		if(has_next_point()):
			for point in next_points:
				draw_line(Vector2(), get_transform().affine_inverse() * point.position, Color(1,0,0,1), -1)
		if(has_prev_point):
			draw_line(Vector2(), get_transform().affine_inverse() * prev_point.position, Color(0,0,1,1), -1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()
