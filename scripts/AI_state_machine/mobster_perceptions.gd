class_name MobsterPerceptions
extends Perceptions

var target_pos = Vector2(0,0) #last point where the target was seen
var target_obj : Node #reference to the target itself
var has_line_of_sight_to_target = false
var reactive_has_line_of_sight_to_target = false
var team = ""
var opposing_team = ""
var hit_points
var invincible = false

