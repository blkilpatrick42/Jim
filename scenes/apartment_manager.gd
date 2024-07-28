extends Node2D

@onready var _bed_slot = $bed_slot
@onready var _desk_slot = $desk_slot
@onready var _night_stand_slot = $night_stand_slot

func set_bed_slot(bed : Node):
	_bed_slot.get_children()[0].queue_free()
	_bed_slot.add_child(bed)

func set_desk_slot(desk : Node):
	_desk_slot.get_children()[0].queue_free()
	_desk_slot.add_child(desk)

func set_night_stand_slot(night_stand : Node):
	_night_stand_slot.get_children()[0].queue_free()
	_night_stand_slot.add_child(night_stand)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
