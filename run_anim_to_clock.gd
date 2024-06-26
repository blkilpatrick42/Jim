extends AnimatedSprite2D

@export var turns_on = 0
@export var turns_off = 23

var time_keeper = null


# Called when the node enters the scene tree for the first time.
func _ready():
	time_keeper = get_tree().get_first_node_in_group("time_keeper")
	play("off")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(time_keeper.clock == turns_on):
		play("running")
	elif(time_keeper.clock == turns_off):
		play("off")
