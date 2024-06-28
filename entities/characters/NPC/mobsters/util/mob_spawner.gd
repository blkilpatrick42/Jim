extends Node2D

var mobster = preload("res://entities/characters/NPC/mobsters/mobster.tscn")

var max_mobs_per_team = 20

var respawn_timer = Timer.new()
var timer_time_seconds = 30
var ysort_node
@export var spawner_team = "red"

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	respawn_timer.one_shot = true
	add_child(respawn_timer)
	ysort_node = get_tree().get_first_node_in_group("daylight_affected_ysort")
	respawn_timer.start(timer_time_seconds)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var num_current_mobs = 0
	var current_mobs = get_tree().get_nodes_in_group("mobster")
	var current_team_nodes = get_tree().get_nodes_in_group(spawner_team)
	for mob in current_mobs:
		if(mob in current_team_nodes):
			num_current_mobs+=1
	
	if(respawn_timer.is_stopped() && num_current_mobs < max_mobs_per_team):
		var new_mob = mobster.instantiate()
		new_mob.set_team(spawner_team)
		ysort_node.add_child(new_mob)
		new_mob.position = position
		respawn_timer.start(timer_time_seconds)
