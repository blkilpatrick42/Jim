extends Node
@export var song_deck : Array[String]

var time_keeper = null
var main_music_player = null
var internal_clock = 0

var active = false

func get_song_deck():
	return song_deck

# Called when the node enters the scene tree for the first time.
func _ready():
	time_keeper = get_tree().get_first_node_in_group("time_keeper")
	main_music_player = get_tree().get_first_node_in_group("main_music_player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(internal_clock != time_keeper.clock &&
	active == true):
		internal_clock = time_keeper.clock
		if(song_deck.size() > 1 &&
		song_deck[internal_clock] != ""):
			var new_stream = get_song_deck()[internal_clock]
			main_music_player.change_stream(new_stream)
		elif(song_deck.size() == 1):
			var new_stream = get_song_deck()[0]
			main_music_player.change_stream(new_stream)
			

func _on_body_entered(body : Node):
	if(body.is_in_group("player") && !active):
		active = true
		var new_stream
		if(song_deck.size() > 1):
			new_stream = get_song_deck()[internal_clock]
		else:
			new_stream = get_song_deck()[0] 
		main_music_player.change_stream(new_stream)

func _on_body_exited(body : Node):
	if(body.is_in_group("player") && active):
		main_music_player.change_stream("")
		active = false
