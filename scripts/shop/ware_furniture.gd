extends Node

@export var furniture_entity : PackedScene

@export var is_bed = false
@export var is_desk = false
@export var is_night_stand = false

func get_is_bed():
	return is_bed

func get_is_desk():
	return is_desk

func get_is_night_stand():
	return is_night_stand

func run_script():
	var apartment_manager = get_tree().get_first_node_in_group("apartment_manager")
	var entity = furniture_entity.instantiate()
	if(get_is_bed()):
		apartment_manager.set_bed_slot(entity)
	elif(get_is_desk()):
		apartment_manager.set_desk_slot(entity)
	elif(get_is_night_stand()):
		apartment_manager.set_night_stand_slot(entity)
