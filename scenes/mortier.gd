extends Spatial

onready var mesh: MeshInstance = $MeshInstance
onready var tween: Tween = $Tween
var cnt: float = 0
var delay: float = 0
var from: Vector3 = Vector3.ZERO
var dest_vector: Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func fire(from: Vector3, to: Vector3, delay: float):
	self.global_transform.origin = from
	self.cnt = 0
	self.delay = delay
	self.from = from
	self.dest_vector = to - from
#	self.speed_vec = (to - from).normalized() * delay
	
#	tween.interpolate_property(mesh, "position.x",
#        Vector2(0, 0), Vector2(100, 100), 1,
#        Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#	tween.start()

func _process(delta):
	if delay == 0.0:
		return 
		
	cnt += delta
	var percent = cnt / delay
	
	var pos = self.from
	pos.x += dest_vector.x * percent
	pos.z += dest_vector.z * percent
	
	pos.y += (1.0 - pow(2 * percent - 1, 2)) * 5
	
	mesh.global_transform.origin = pos
	
	if percent >= 1.0:
		emit_signal("hit")
		self.queue_free()
	

#
#func _physics_process(delta):
#	velocity += g * delta
#	look_at(transform.origin + velocity.normalized(), Vector3.UP)
#	transform.origin += velocity * delta

#func _on_mortier_body_entered(body):
#	queue_free()
#	pass # Replace with function body.
