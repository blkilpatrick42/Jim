class_name ai_state_machine
extends Node

# Emitted when transitioning to a new state.
signal transitioned(state_name)

@export var initial_state := NodePath()

@onready var state: State = get_node(initial_state)

var perceptions : MobsterPerceptions

func _ready():
	# The state machine assigns itself to the State objects' state_machine property.
	for child in get_children():
		child.ai_state_machine = self
	state.enter()

func get_perceptions():
	return perceptions

func receive_perceptions(host_perceptions: MobsterPerceptions):
		perceptions = host_perceptions
		var blah = 0

func _process(delta: float):
	if(!Engine.is_editor_hint()):
		state.process(delta)

func _physics_process(delta: float):
	if(!Engine.is_editor_hint()):
		state.physics_process(delta)

func transition_to(target_state_name: String, msg: Dictionary = {}):
	var transition_node = get_node(target_state_name)
	if (transition_node == null):
		return

	state.exit()
	state = transition_node
	state.enter(msg)
	emit_signal("transitioned", state.name)
