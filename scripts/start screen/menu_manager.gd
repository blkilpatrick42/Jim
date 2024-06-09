extends Node
@onready var attribution = $attribution


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_input():
	if Input.is_action_just_pressed("start"):
		get_tree().change_scene_to_file("res://scenes/dev_base_3.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_input()
