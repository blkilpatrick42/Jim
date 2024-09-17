extends Node2D

var main_scene = preload("res://scenes/alpha_game_world_draft4.tscn")
var camera_ref : Node
var player_ref

var transition_timer = Timer.new()
var transitioning = false
var prev_scene_freed = false

func _ready():
	camera_ref = get_tree().get_first_node_in_group("camera")
	transition_timer.one_shot = true
	self.add_child(transition_timer)

#root manager transitions from current scene (presumably start) to main scene
func _on_transition_to_main_scene_init():
	camera_ref.fade_out()
	transitioning = true
	transition_timer.start(3)
	prev_scene_freed = false

#callback from active_root when the scene is ready
func _on_transition_to_main_Scene_finished():
	player_ref = get_tree().get_first_node_in_group("player")
	camera_ref.reparent(player_ref)
	player_ref.connect_camera()
	camera_ref.fade_in()
	player_ref.set_ui_visible()
	transitioning = false
	
func _process(delta):
	if(transition_timer.is_stopped() && transitioning && !prev_scene_freed):
		var active_root = get_tree().get_first_node_in_group("active_root")
		active_root.queue_free()
		prev_scene_freed = true
		var main_scene = main_scene.instantiate()
		add_child(main_scene)

