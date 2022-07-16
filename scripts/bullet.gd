extends Area

var speed_vec = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
#func move_towards(target: Vector3, speed: float):
#	look_at(target, Vector3.UP)
#	speed_vec = (target - self.translation).normalized() * speed
	
func fire(from: Vector3, to: Vector3, speed: float, is_enemy: bool):
	from = Vector3(from.x, 0.5, from.z)
	to = Vector3(to.x, 0.5, to.z)
	self.translation = from
	self.speed_vec = (to - from).normalized() * speed
	self.look_at(to, Vector3.UP)
	
	if is_enemy:
		self.set_collision_mask_bit(2, false) # mask for hitting enemies
		$MeshInstance.get_surface_material(0).albedo_color = Color.orangered
	else:
		self.set_collision_mask_bit(4, false) # mask for hitting player
		$MeshInstance.get_surface_material(0).albedo_color = Color.blue


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.translation += speed_vec * delta
	print(self.translation)
#	if abs(self.translation.x) > 100 || abs(self.translation.y) > 100:
#		self.queue_free()


func _on_Bullet_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	print("bullet hit ", body.name, " layers=", body.get_collision_layer(), " mask=", body.get_collision_mask())
	print("bullet hit self: ", self.name, " layers=", self.get_collision_layer(), " mask=", self.get_collision_mask())
	if(body.name == "Player"):
		self.disconnect("area_shape_entered", self, "_on_Bullet_body_shape_entered")
		body.on_bullet_hit(speed_vec.normalized())
	self.queue_free()
