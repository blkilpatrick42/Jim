extends Node2D
@onready var neon_glow = $neon_glow
@onready var sprite = $AnimatedSprite2D

@export var linked_mob_spawner : Node2D

func _physics_process(delta: float) -> void:
	if(linked_mob_spawner.spawner_team == "red"):
		neon_glow.color = Color(1.0, 0.0, 0.0)
		sprite.frame = 9
	elif(linked_mob_spawner.spawner_team == "blu"):
		neon_glow.color = Color(0.0, 0.0, 1.0)
		sprite.frame = 0
