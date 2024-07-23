extends StaticBody2D

signal comment(text : String)

var time_keeper = null

# Called when the node enters the scene tree for the first time.
func _ready():
	time_keeper = get_tree().get_first_node_in_group("time_keeper")

func interact():
	comment.emit(str("It is ", time_keeper.get_informal_time_string()))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
