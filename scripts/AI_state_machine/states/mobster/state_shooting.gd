class_name Shooting_State
extends State

signal shoot(pos : Vector2, rotation_deg)
signal play_animation(name : String)
signal face_target()
signal stop_motion()
signal reduce_health()
signal drop_item()

#gun-related variables
const bust_num_sweeps = 2
const burst_bullets_per_sweep = 4
const burst_num_bullets = bust_num_sweeps * burst_bullets_per_sweep
const burst_cool_down_secs = 2
var timer_burst_cool_down : Timer
const time_between_shots_secs = 0.4
var timer_between_shots : Timer
const shoot_arc_degrees = 50 #keep it even
var num_bullets_fired = 0
var lower_bound = 0
var upper_bound = 0
var reverse_sweep = false
var burst_cool_down = false

func set_shoort_arc_bounds():
	var half_arc = shoot_arc_degrees / 2
	match(ai_state_machine.get_perceptions().facing_dir):
		direction.right:
			lower_bound = 0 - half_arc
			upper_bound = 0 + half_arc
		direction.left:
			lower_bound = 180 - half_arc
			upper_bound = 180 + half_arc
		direction.up:
			lower_bound = 270 - half_arc
			upper_bound = 270 + half_arc
		direction.down:
			lower_bound = 90 - half_arc
			upper_bound = 90 + half_arc

func create_bullet():
	var bullet_spawn_point = ai_state_machine.get_perceptions().position
	var half_arc = shoot_arc_degrees / 2
	var spawn_distance = 20
	var gun_pos_tweak = 5
	match(ai_state_machine.get_perceptions().facing_dir):
		direction.right:
			bullet_spawn_point = bullet_spawn_point + Vector2(spawn_distance,0)
		direction.left:
			bullet_spawn_point = bullet_spawn_point + Vector2(-spawn_distance,0)
		direction.up:
			bullet_spawn_point = bullet_spawn_point + Vector2(gun_pos_tweak,-spawn_distance)
		direction.down:
			bullet_spawn_point = bullet_spawn_point + Vector2(-gun_pos_tweak,spawn_distance)
	
	var arc_segment_degrees = shoot_arc_degrees / burst_bullets_per_sweep
	var current_segment = num_bullets_fired 
	while(current_segment > burst_bullets_per_sweep):
		reverse_sweep = !reverse_sweep
		current_segment = current_segment - burst_bullets_per_sweep
	
	var current_arc = 0
	if(reverse_sweep):
		current_arc = (upper_bound - (arc_segment_degrees * current_segment))
	else:
		current_arc = (lower_bound + (arc_segment_degrees * current_segment))
	
	shoot.emit(bullet_spawn_point, current_arc)

func shoot_burst():
	face_target.emit()
	set_shoort_arc_bounds()
	play_animation.emit(str("shoot_",ai_state_machine.get_perceptions().facing_dir))
	if(timer_between_shots.is_stopped() 
		&& num_bullets_fired < burst_num_bullets):
		if(ai_state_machine.get_perceptions().has_line_of_sight_to_target):
			create_bullet()
		num_bullets_fired = num_bullets_fired + 1
		timer_between_shots.start(time_between_shots_secs)
	else: if(num_bullets_fired >= burst_num_bullets):
		burst_cool_down = true
		timer_burst_cool_down.start(burst_cool_down_secs)	

func handle_sparks():
	if(ai_state_machine.get_perceptions().colliding_nodes.size() > 0):
		for node in ai_state_machine.get_perceptions().colliding_nodes:
				if(is_instance_valid(node) && node.is_in_group("spark")):
					if(node.is_in_group(ai_state_machine.get_perceptions().opposing_team) &&
					!ai_state_machine.get_perceptions().invincible):
						reduce_health.emit()
						return true
	return false

func handle_death():
	if(ai_state_machine.get_perceptions().hit_points <= 0):
		ai_state_machine.transition_to(ai_state_machine.falling)
		return true
	return false

func process(_delta: float) -> void:
	pass

func physics_process(_delta: float) -> void:
	#check for enemy bullet collisions
	if(handle_sparks()):
		return
	elif(handle_death()):
		return
	else: #shooting code
		if(!burst_cool_down):
			shoot_burst()
		if(timer_burst_cool_down.is_stopped() && burst_cool_down):
			burst_cool_down = false
			num_bullets_fired = 0
			if(!ai_state_machine.get_perceptions().has_line_of_sight_to_target):
				ai_state_machine.transition_to(ai_state_machine.chasing)
			else:
				ai_state_machine.transition_to(ai_state_machine.strafing)

func enter(_msg := {}) -> void:
	stop_motion.emit()
	drop_item.emit()
	timer_burst_cool_down = Timer.new()
	timer_burst_cool_down.one_shot = true
	add_child(timer_burst_cool_down)
	timer_between_shots = Timer.new()
	timer_between_shots.one_shot = true
	add_child(timer_between_shots)
	num_bullets_fired = 0

func exit() -> void:
	timer_burst_cool_down.queue_free()
	timer_between_shots.queue_free()
