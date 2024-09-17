extends Node

var root_manager
var main_camera

# Called when the node enters the scene tree for the first time.
func _ready():
	root_manager = get_tree().get_first_node_in_group("root_manager")
	main_camera = get_tree().get_first_node_in_group("camera")

func _process(_delta):
	if(main_camera.is_faded_out()):
		#if everything is ready and the scene is running, complete transition on the manager end
		root_manager._on_transition_to_main_Scene_finished()
