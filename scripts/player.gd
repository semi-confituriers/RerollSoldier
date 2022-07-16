extends KinematicBody

# How fast the player moves in meters per second.
export var speed = 14
# The downward acceleration when in the air, in meters per second squared.
export var fall_acceleration = 75

var velocity = Vector3.ZERO

var can_fire = true


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	# We create a local variable to store the input direction.
	var direction = Vector3.ZERO

	# We check for each move input and update the direction accordingly.
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_down"):
		direction.z += 1
	if Input.is_action_pressed("move_up"):
		direction.z -= 1
		
	if Input.is_action_pressed("fire") && can_fire:
		fire("beam-cross")
		can_fire = false
		yield(get_tree().create_timer(0.5), "timeout")
		can_fire = true
		
		
	if direction != Vector3.ZERO:
		direction = direction.normalized()
#		$Pivot.look_at(translation + direction, Vector3.UP)
	# Ground velocity
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	# Vertical velocity
	velocity.y -= fall_acceleration * delta
	
	# Moving the character
	velocity = move_and_slide(velocity, Vector3.UP)


# Called by bullet.gd
func on_bullet_hit(hit_dir: Vector3):
	$Camera.bump(hit_dir)
	$Camera.kick_out()
	
func fire(pattern: String, color: Color = Color.red):
	print("player-fire: ", pattern)
	match pattern:
		"beam-cross":
			var beams = []
			var beam: Spatial = load("res://scenes/beam.tscn").instance()
			self.add_child(beam)
			beams.append(beam)
			beam.set_color(color)
			var coll_area: Area = beam.get_node("Area")
			coll_area.set_collision_mask_bit(4, false) # Disable coll with player
			
			for i in range(1, 4):
				var other_beam: Spatial = beam.duplicate()
				other_beam.rotate_y(i * PI/2);
				self.add_child(other_beam)
				beams.append(other_beam)
			
			yield(get_tree().create_timer(0.2), "timeout")
			for node in beams:
				node.queue_free()
		"bullet-cross":
			var dir = Vector3.FORWARD
			for i in range(0, 4):
				var this_dir = dir.rotated(Vector3.UP, i * PI/2)
				var bullet: Spatial = load("res://scenes/bullet.tscn").instance()
				get_node("/root/Arena").add_child(bullet)
				
				var from = self.translation
#				var from = self.global_transform.origin
				bullet.fire(from, from + this_dir, 40, false)

