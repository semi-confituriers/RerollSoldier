extends Area

export var damage: int = 1

var speed_vec = Vector3.ZERO
var colored_materials = {}

const colorMap = {
	"green": Color.green,
	"red": Color.orangered,
	"yellow": Color.yellow
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

#func move_towards(target: Vector3, speed: float):
#	look_at(target, Vector3.UP)
#	speed_vec = (target - self.translation).normalized() * speed
	
func fire(from: Vector3, to: Vector3, speed: float, is_enemy: bool, color:String):
	to.y = from.y
	self.translation = from
	self.speed_vec = (to - from).normalized() * speed
	self.look_at(to, Vector3.UP)
	
	if not color in colored_materials:
		colored_materials[color] = $MeshInstance.get_surface_material(0).duplicate()
		colored_materials[color].albedo_color = colorMap[color]
	$MeshInstance.set_surface_material(0, colored_materials[color])
	
	if is_enemy:
#		print("Enemy coll mask: ", self.get_collision_mask())
#		self.set_collision_mask_bit(2, false) # mask for hitting enemies
#		print(" -> Enemy coll mask: ", self.get_collision_mask())
		self.set_collision_mask(0b011)

	else:
		self.set_collision_mask(0b101)
#		print("Player coll mask: ", self.get_collision_mask())
#		self.set_collision_mask_bit(1, false) # mask for hitting player
#		print(" -> Player coll mask: ", self.get_collision_mask())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.translation += speed_vec * delta
	if abs(self.translation.x) > 100 || abs(self.translation.y) > 100:
		self.queue_free()


func _on_Bullet_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body.name != "Borders":
		print("bullet hit ", body.name, " layers=", body.get_collision_layer(), " mask=", body.get_collision_mask())
		print("bullet hit self: ", self.name, " layers=", self.get_collision_layer(), " mask=", self.get_collision_mask())
	if body.name == "Player" || body.get_parent().name == "Enemies":
		self.disconnect("area_shape_entered", self, "_on_Bullet_body_shape_entered")
		body.on_hit(self.damage, speed_vec.normalized())
	self.queue_free()
