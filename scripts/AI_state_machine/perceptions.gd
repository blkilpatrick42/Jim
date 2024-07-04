class_name Perceptions

var position = Vector2(0,0)
var current_v = Vector2(0,0) #force applied this physics frame
var linear_velocity = Vector2(0,0)
var speed = 0
var nav_target_reached = false
var animation_running = false
var facing_dir = "left"
var one_shot_animating = false
var colliding_nodes: Array[Node] = []
var nodes_in_vision: Array[Node] = []
var nodes_in_hearing: Array[Node] = []
var holding_object = false
