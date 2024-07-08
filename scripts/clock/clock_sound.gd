extends AudioStreamPlayer2D

@export var song_deck : Array[String]

var time_keeper = null
var internal_clock = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	time_keeper = get_tree().get_first_node_in_group("time_keeper")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(internal_clock != time_keeper.clock):
		internal_clock = time_keeper.clock
		if(song_deck[internal_clock] != ""):
			stream = load(song_deck[internal_clock])
			play()
