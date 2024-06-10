extends Node

@onready var panel1 = $panel1
@onready var panel2 = $panel2
@onready var panel3 = $panel3

var switch_point = -720

var windows : Array[Node] = []
var timer : Timer = Timer.new()

@export var timer_wait_secs = 0.01

# Called when the node enters the scene tree for the first time.
func _ready():
	windows.append(panel3)
	windows.append(panel1)
	windows.append(panel2)
	timer.one_shot = true
	add_child(timer)
	timer.start(timer_wait_secs)

func shift_scrollers(pixels : int):
	for panel in windows:
		panel.global_position.y -= pixels

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var jump_distance = 1440
	if(timer.is_stopped()):
		shift_scrollers(1)
		timer.start(timer_wait_secs)
	if(panel1.global_position.y <= switch_point):
		panel1.global_position.y += jump_distance
	if(panel2.global_position.y <= switch_point):
		panel2.global_position.y += jump_distance
	if(panel3.global_position.y <= switch_point):
		panel3.global_position.y += jump_distance
