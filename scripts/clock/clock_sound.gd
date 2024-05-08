extends AudioStreamPlayer2D

@export var play_0 = ""
@export var play_1 = ""
@export var play_2 = ""
@export var play_3 = ""
@export var play_4 = ""
@export var play_5 = ""
@export var play_6 = ""
@export var play_7 = ""
@export var play_8 = ""
@export var play_9 = ""
@export var play_10 = ""
@export var play_11 = ""
@export var play_12 = ""
@export var play_13 = ""
@export var play_14 = ""
@export var play_15 = ""
@export var play_16 = ""
@export var play_17 = ""
@export var play_18 = ""
@export var play_19 = ""
@export var play_20 = ""
@export var play_21 = ""
@export var play_22 = ""
@export var play_23 = ""

var time_keeper = null
var internal_clock = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	time_keeper = get_tree().get_first_node_in_group("time_keeper")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(internal_clock != time_keeper.clock):
		internal_clock = time_keeper.clock
		match internal_clock:
			0:
				if(play_0 != ""):
					stream = load(str("res://audio/",play_0))
					play()
			1:
				if(play_1 != ""):
					stream = load(str("res://audio/",play_1))
					play()
			2:
				if(play_2 != ""):
					stream = load(str("res://audio/",play_2))
					play()
			3:
				if(play_3 != ""):
					stream = load(str("res://audio/",play_3))
					play()
			4:
				if(play_4 != ""):
					stream = load(str("res://audio/",play_4))
					play()
			5: 
				if(play_5 != ""):
					stream = load(str("res://audio/",play_5))
					play()
			6:
				if(play_6 != ""):
					stream = load(str("res://audio/",play_6))
					play()
			7:
				if(play_7 != ""):
					stream = load(str("res://audio/",play_7))
					play()
			8:
				if(play_8 != ""):
					stream = load(str("res://audio/",play_8))
					play()
			9:
				if(play_9 != ""):
					stream = load(str("res://audio/",play_9))
					play()
			10:
				if(play_10 != ""):
					stream = load(str("res://audio/",play_10))
					play()
			11:
				if(play_11 != ""):
					stream = load(str("res://audio/",play_11))
					play()
			12:
				if(play_12 != ""):
					stream = load(str("res://audio/",play_12))
					play()
			13:
				if(play_13 != ""):
					stream = load(str("res://audio/",play_13))
					play()
			14:
				if(play_14 != ""):
					stream = load(str("res://audio/",play_14))
					play()
			15:
				if(play_15 != ""):
					stream = load(str("res://audio/",play_15))
					play()
			16:
				if(play_16 != ""):
					stream = load(str("res://audio/",play_16))
					play()
			17:
				if(play_17 != ""):
					stream = load(str("res://audio/",play_17))
					play()
			18:
				if(play_18 != ""):
					stream = load(str("res://audio/",play_18))
					play()
			19:
				if(play_19 != ""):
					stream = load(str("res://audio/",play_19))
					play()
			20:
				if(play_20 != ""):
					stream = load(str("res://audio/",play_20))
					play()
			21:
				if(play_21 != ""):
					stream = load(str("res://audio/",play_21))
					play()
			22:
				if(play_22 != ""):
					stream = load(str("res://audio/",play_22))
					play()
			23:
				if(play_23 != ""):
					stream = load(str("res://audio/",play_23))
					play()
