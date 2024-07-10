extends Node

@onready var _DialogBubble = $DialogBubble
@onready var _ResponseBubble = $ResponseBubble

var speaker_node : Node
var tree : dialog_tree
var player_ref
var dialog_choice_index = 0
var responding = false
var dialog_started = false

func set_speaker_node(node : Node):
	speaker_node = node

# Called when the node enters the scene tree for the first time.
func _ready():
	player_ref = get_tree().get_first_node_in_group("player")
	_DialogBubble.visible = false
	_ResponseBubble.visible = false

func play_current_branch():
	responding = false
	_ResponseBubble.visible = false
	_DialogBubble.visible = true
	_DialogBubble.set_portrait(tree.get_speaker_portrait(), tree.get_speaker_emote())
	_DialogBubble.play_text(tree.get_speaker_text(), tree.get_voice())

func set_tree_and_start_dialog(in_tree :dialog_tree):
	tree = in_tree
	dialog_started = true
	_DialogBubble.visible = true
	play_current_branch()

func is_end_of_dialog() -> bool:
	return tree.get_num_speech_options() == 0 && tree.get_num_option_branches() == 0

func dialog_continues() -> bool:
	return tree.get_num_speech_options() == 0 && tree.get_num_option_branches() == 1

func has_speech_options() -> bool:
	return tree.get_num_speech_options() > 0
	
func handle_input():
	if(responding):
		_ResponseBubble.set_label(tree.get_speech_option(dialog_choice_index))
		
	if(Input.is_action_just_pressed("left")):
		if(dialog_choice_index == 0):
			dialog_choice_index = tree.get_num_speech_options() - 1
		else:
			dialog_choice_index = dialog_choice_index - 1
	
	if(Input.is_action_just_pressed("right")):
		if(dialog_choice_index == tree.get_num_speech_options() - 1):
			dialog_choice_index = 0
		else:
			dialog_choice_index = dialog_choice_index + 1
		
	if(Input.is_action_just_pressed("interact")):
		#no options or next nodes = dialog is over
		if(is_end_of_dialog()):
			tree.reset()
			player_ref.exit_dialog()
			queue_free()
		elif(dialog_continues()):
			tree.take_speech_option(0)
			play_current_branch()
		elif(has_speech_options() && !responding):
			_DialogBubble.visible = false
			_ResponseBubble.visible = true
			responding = true
		elif(has_speech_options() && responding):
			tree.take_speech_option(dialog_choice_index)
			play_current_branch()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(dialog_started):
		_DialogBubble.global_position = speaker_node.global_position + Vector2(-48,-96)
		_ResponseBubble.global_position = player_ref.global_position + Vector2(-48,-96)
		if(_DialogBubble.is_text_done_playing()):
			handle_input()

func set_dialog_tree(in_tree : dialog_tree):
	tree = in_tree
