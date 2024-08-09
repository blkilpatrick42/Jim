class_name stage_mark
extends Node2D

@export var state : String

#TODO: this is setting up a situation where we're gonna need waaay too many stage_marks + schedules
#to support the more complex/varying characters. consider how to do more subtle iteration within the stage_mark?
@export var branching_dialog : dialog_tree

@export var passive_text : Array[String] = []

var random = RandomNumberGenerator.new()

func get_state():
	return state

func get_branching_dialog():
	return branching_dialog

func virtual_passive_text():
	return passive_text

func get_passive_text() -> String:
	if(passive_text.size() > 0):
		return virtual_passive_text()[random.randi_range(0, passive_text.size() - 1)]
	else:
		return ""
