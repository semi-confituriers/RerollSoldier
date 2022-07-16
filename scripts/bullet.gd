extends Area

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


func _on_Bullet_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	print("_on_Bullet_body_shape_entered", body)
	if(body.name == "Player"):
		self.disconnect("area_shape_entered", self, "_on_Bullet_body_shape_entered")
		self.queue_free()
		body.on_bullet_hit(speed_vec.normalized())
	pass # Replace with function body.
