extends Area

export var fire_velocity = 25
export var g = Vector3.DOWN * 20

var velocity = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func fire(from: Vector3, to: Vector3, speed: float): 
	self.transform.origin = from
	self.speed_vec = (to - from).normalized() * speed
	self.look_at(to, Vector3.UP)

func _physics_process(delta):
	velocity += g * delta
	look_at(transform.origin + velocity.normalized(), Vector3.UP)
	transform.origin += velocity * delta

#func _on_mortier_body_entered(body):
#	queue_free()
#	pass # Replace with function body.
