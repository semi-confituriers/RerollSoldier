extends StaticBody

var speed_vec = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func move_towards(target: Vector3, speed: float):
	look_at(target, Vector3.UP)
	speed_vec = (target - self.translation).normalized() * speed
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.translation += speed_vec * delta
	if abs(self.translation.x) > 100 || abs(self.translation.y) > 100:
		self.queue_free()
