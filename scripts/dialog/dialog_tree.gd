class_name dialog_tree
extends Node

@export var trunk := NodePath()

@onready var current_branch: dialog_branch = get_node(trunk)

func reset():
	current_branch = get_node(trunk)

func get_speaker_portrait() -> SpriteFrames:
	return current_branch.get_speaker_portrait()

func get_speaker_emote() -> String:
	return current_branch.get_speaker_emote()

func get_voice() -> String:
	return current_branch.get_voice()

func get_speaker_text() -> String:
	return current_branch.get_speaker_text()

func get_speech_options() -> Array[String]:
	return current_branch.get_speech_options()

func get_speaker_name() -> String:
	return current_branch.get_speaker_name()

func get_speech_option(index : int) -> String:
	return current_branch.get_speech_options()[index]

func get_num_speech_options() -> int:
	return current_branch.get_speech_options().size()

func get_option_branches() -> dialog_branch:
	return current_branch.get_option_branches()

func get_dialog_script() -> Node:
	return current_branch.get_dialog_script()

func get_shows_wares() -> bool:
	return current_branch.get_shows_wares()

func set_speech_options(options : Array[String]):
	current_branch.set_speech_options(options)

func get_num_option_branches() -> int:
	return current_branch.get_option_branches().size()

func take_speech_option(index : int):
	current_branch = current_branch.get_option_branch(index)

func get_give_money_amount() -> int:
	return current_branch.get_gives_money()
