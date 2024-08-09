class_name schedule
extends Node

#daily schedule nodes for each of the week's days
#should have size of 7 (duh)
@export var daily_schedules : Array[daily_schedule] = []

func get_stage_mark(day : int, hour : int):
	return daily_schedules[day].get_stage_mark(hour)
