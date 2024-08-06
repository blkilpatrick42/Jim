extends Node

@onready var _DialogBubble = $DialogBubble
@onready var _ResponseBubble = $ResponseBubble

var speaker_node : Node
var tree : dialog_tree
var player_ref
var dialog_choice_index = 0
var responding = false
var shopping = false
var dialog_started = false
var shop : shop_manager = null

func set_shop(new_shop : shop_manager):
	shop = new_shop

func set_speaker_node(node : Node):
	speaker_node = node

# Called when the node enters the scene tree for the first time.
func _ready():
	player_ref = get_tree().get_first_node_in_group("player")
	_DialogBubble.visible = false
	_ResponseBubble.visible = false

func play_current_branch():
	responding = false
	if(tree.get_speaker_name() != null && tree.get_speaker_name() != ""):
		speaker_node = get_tree().get_first_node_in_group(tree.get_speaker_name())
		
	_ResponseBubble.visible = false
	_DialogBubble.visible = true
	_DialogBubble.set_portrait(tree.get_speaker_portrait(), tree.get_speaker_emote())
	_DialogBubble.play_text(tree.get_speaker_text(), tree.get_voice())
	
	var branch_gives_money_amount = tree.get_give_money_amount()
	if(branch_gives_money_amount > 0):
		player_ref._on_add_money(branch_gives_money_amount)
	var branch_script = tree.get_dialog_script()
	if(branch_script != null):
		branch_script.run_script()

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
		if(tree.get_shows_wares() && shop != null): #display available wares
			shopping = true
			if(dialog_choice_index == 0):
				_ResponseBubble.set_label("Nevermind")
			else:
				_ResponseBubble.set_label(shop.get_staged_wares()[dialog_choice_index-1].get_ware_name())
		else:
			_ResponseBubble.set_label(tree.get_speech_option(dialog_choice_index))
			
		if(Input.is_action_just_pressed("left")):
			if(dialog_choice_index == 0):
				if(!shopping):
					dialog_choice_index = tree.get_num_speech_options() - 1
				else:
					dialog_choice_index = shop.get_staged_wares().size()
			else:
				dialog_choice_index = dialog_choice_index - 1
		
		if(Input.is_action_just_pressed("right")):
			if(!shopping):
				if(dialog_choice_index == tree.get_num_speech_options() - 1):
					dialog_choice_index = 0
				else:
					dialog_choice_index = dialog_choice_index + 1
			else:
				if(dialog_choice_index == shop.get_staged_wares().size()):
					dialog_choice_index = 0
				else:
					dialog_choice_index = dialog_choice_index + 1
		
	if(Input.is_action_just_pressed("interact")):
		#no options or next nodes = dialog is over
		if(is_end_of_dialog()):
			tree.reset()
			player_ref.exit_dialog()
			clean_up()
		elif(dialog_continues()):
			tree.take_speech_option(0)
			play_current_branch()
		elif(has_speech_options() && !responding):
			_DialogBubble.visible = false
			_ResponseBubble.visible = true
			responding = true
		elif(has_speech_options() && responding):
			if(!shopping):
				tree.take_speech_option(dialog_choice_index)
				play_current_branch()
			else:
				var player_money = player_ref.get_money()
				var ware = shop.get_staged_wares()[dialog_choice_index-1]
				if(dialog_choice_index == 0):
					tree.take_speech_option(0) #"nevermind" don't buy anything
					play_current_branch()
				elif(player_money >= ware.get_cost()):
					ware.buy_item()
					tree.take_speech_option(1)
					play_current_branch()
				elif(player_money < ware.get_cost()):
					tree.take_speech_option(2) #"not enough money" don't buy anything
					play_current_branch()
				

func clean_up():
	var children = get_children()
	for child in children:
		child.queue_free()
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(dialog_started):
		_DialogBubble.global_position = speaker_node.global_position + Vector2(-48,-96)
		_ResponseBubble.global_position = player_ref.global_position + Vector2(-48,-96)
		if(_DialogBubble.is_text_done_playing()):
			handle_input()

func set_dialog_tree(in_tree : dialog_tree):
	tree = in_tree
