extends Node
class_name shop_manager

@export var wares : Array[PackedScene] = []
@export var stage_locations : Array[Node] = []

var staged_wares : Array[Node] = []

var random = RandomNumberGenerator.new()

var wares_staged = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func dispose_of_staged_wares():
	for ware in staged_wares:
		ware.queue_free()
	staged_wares = []

#TODO: hook this up to a signal from time keeper
func shuffle_staged_items():
	dispose_of_staged_wares()
	var indices : Array[int] =[]
	var iterator = 0
	while(iterator < stage_locations.size()):
		var index = random.randi_range(0,wares.size()-1)
		if (!indices.has(index)):
			indices.append(index)
			var ware = wares[index].instantiate()
			stage_locations[iterator].add_child(ware)
			ware.global_position = stage_locations[iterator].global_position
			staged_wares.append(ware)
			iterator += 1

func get_staged_wares():
	return staged_wares

func buy_ware(index : int):
	staged_wares[index].buy_item()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(!wares_staged):
		shuffle_staged_items()
		wares_staged = true
