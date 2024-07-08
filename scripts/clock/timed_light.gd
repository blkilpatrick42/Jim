extends PointLight2D

@export var running_hours : Array[bool]

var time_keeper = null

# Called when the node enters the scene tree for the first time.
func _ready():
	time_keeper = get_tree().get_first_node_in_group("time_keeper")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	enabled = running_hours[time_keeper.clock]
