extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_accept"):
		fire_bullet(get_node("/root/Arena/Player").translation, 20)



func fire_bullet(target: Vector3, speed: float):
	var bullet_inst = load("res://scenes/bullet.tscn").instance()
	get_node("/root/Arena").add_child(bullet_inst)
	bullet_inst.translation = self.translation
	bullet_inst.move_towards(target, speed)
