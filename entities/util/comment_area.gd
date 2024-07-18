extends StaticBody2D

signal make_comment(String)

@export var text : String

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func interact():
	make_comment.emit(text)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
