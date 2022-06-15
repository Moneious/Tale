extends Light2D

onready var base_time = 0

func _process(delta):
	# self.transform.origin = 
	if base_time < 2 * PI:
		base_time += delta * 2
	else:
		base_time = 0
	var length = sqrt(abs(cos(2 * base_time)))
	var dx = length * cos(2 * base_time) * 30
	var dy = length * sin(2 * base_time) * 30
	# print(dx, dy)
	self.transform.origin = Vector2(dx, dy)
	# print(self.transform.origin)

