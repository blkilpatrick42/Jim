extends Node2D

var is_occluding_player = false
@onready var sprite = $Sprite2D

var timer = Timer.new()
var fade_step_degree = 0.05
var fade_step_time = 0.05
var faded_alpha = 0.5
var current_alpha = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.one_shot = true
	add_child(timer)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(is_occluding_player):
		if(timer.is_stopped() && current_alpha > faded_alpha):
			timer.start(fade_step_time)
			current_alpha -= fade_step_degree
	else:
		if(timer.is_stopped() && current_alpha < 1):
			timer.start(fade_step_time)
			current_alpha += fade_step_degree
	
	sprite.modulate = Color(1,1,1,current_alpha)
		

func _on_vision_collider_body_entered(body):
	if(body.is_in_group("player") || body.is_in_group("mobster")):
		timer.start(fade_step_time)
		is_occluding_player = true


func _on_vision_collider_body_exited(body):
	if(body.is_in_group("player") || body.is_in_group("mobster")):
		timer.start(fade_step_time)
		is_occluding_player = false