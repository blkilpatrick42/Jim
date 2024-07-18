extends RigidBody2D

signal make_comment(String)
signal add_money(int)

@export var amount : int

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func interact():
	make_comment.emit(str("Cool! $",amount))
	add_money.emit(amount)
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
