extends Control

@onready var heart_1 : AnimatedSprite2D = $health_meter/heart_1
@onready var heart_2 : AnimatedSprite2D = $health_meter/heart_2
@onready var heart_3 : AnimatedSprite2D = $health_meter/heart_3
@onready var location_header = $location_header

var hearts : Array[Node] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	hearts = [heart_1, heart_2, heart_3]

func update_hearts(points : int):
	var iterator = 0
	while(iterator < hearts.size()):
		if(iterator < points):
			hearts[iterator].play("active")
		else:
			hearts[iterator].play("inactive")
		iterator+=1

func activate_header(label : String):
	location_header.activate_header(label)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
