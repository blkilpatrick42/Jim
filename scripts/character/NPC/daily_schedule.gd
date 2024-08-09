class_name daily_schedule
extends Node

#stage_mark nodes representing where an NPC should be at a given hour
#should have size of 24 (duh)
@export var hourly_schedule : Array[Node] = []

func get_stage_mark(hour : int) -> Node:
	return hourly_schedule[hour]
