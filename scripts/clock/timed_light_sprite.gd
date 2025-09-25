extends Sprite2D

@export var running_hours : Array[bool]

@export var active_at_low : bool = false #0
@export var active_at_mid : bool = false #1
@export var active_at_hi : bool = false #2

var time_keeper = null




# Called when the node enters the scene tree for the first time.
func _ready():
	time_keeper = get_tree().get_first_node_in_group("time_keeper")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if((SettingsVariables.lighting_index == 0 && active_at_low) ||
	(SettingsVariables.lighting_index == 1 && active_at_mid) ||
	(SettingsVariables.lighting_index == 2 && active_at_hi)):
		visible = running_hours[time_keeper.clock]
	else:
		visible = false
