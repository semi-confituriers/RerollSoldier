extends Area

export var damage: int = 1

var speed_vec = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func fire(from: Vector3, to: Vector3, speed: float): 
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.translation += speed_vec * delta
	if abs(self.translation.x) > 100 || abs(self.translation.y) > 100:
		self.queue_free()
