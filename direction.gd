class_name direction

const right = "right"
const left = "left"
const up = "up"
const down = "down"

static func get_opposite(dir) -> String:
	match(dir):
		right:
			return left
		left:
			return right
		up:
			return down
		down:
			return up
	return right
