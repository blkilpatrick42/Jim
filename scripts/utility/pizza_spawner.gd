extends Node2D

var pizza = preload("res://entities/props/dynamic props/props_dynamic_pickupable/pizza/pizza.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float):
	if(get_tree().get_nodes_in_group("pizza").size() == 0):
		var new_pizza = pizza.instantiate()
		get_parent().add_child(new_pizza)
		new_pizza.global_position = global_position
