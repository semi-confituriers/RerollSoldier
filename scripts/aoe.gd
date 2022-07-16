extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var is_enemy = true
var inside = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func configure(radius: float, delay: float, color: Color, is_enemy_: bool):
	self.set_scale(Vector3(radius, 1, radius))
	$Sprite3D.modulate = color
	
	is_enemy = is_enemy_
	if is_enemy:
		self.set_collision_mask(0b010)
	else:
		self.set_collision_mask(0b100)
		
	yield(get_tree().create_timer(delay), "timeout")
	
	for body in inside:
		body.queue_free()
	
	self.queue_free()

	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Aoe_body_entered(body):
	inside[body] = true

func _on_Aoe_body_exited(body):
	inside.erase(body)
