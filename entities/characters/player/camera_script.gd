extends Camera2D

const height := 16
const width  := 16
const ratio :float= 16.0/16.0
var target : Vector2 = Vector2(1,1)
func _ready():
	print(name," connecting")
	get_viewport().size_changed.connect(size_changed)
	get_window().min_size = Vector2i(height,width)

func size_changed():
	print(get_window().size)
	var size : Vector2i = get_window().size
	if size.y % 2:
		size.y += 1
	size.x = size.y * ratio
	var s = Vector2(size) / Vector2(width,height)
	target = s

func _process(delta):
	if not zoom.is_equal_approx(target):
		zoom = zoom.lerp(target,0.2)
	else:
		zoom = target
