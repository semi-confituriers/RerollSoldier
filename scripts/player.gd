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
	$Camera.fov += 1
	$Camera.translation += hit_dir/2;
	yield(get_tree().create_timer(0.05), "timeout")
	$Camera.translation -= hit_dir;
	yield(get_tree().create_timer(0.05), "timeout")
	$Camera.translation += hit_dir;
	yield(get_tree().create_timer(0.05), "timeout")
	$Camera.translation -= hit_dir/2;
	$Camera.fov -= 1
	
func fire(pattern: String, color: Color = Color.red):
	print("player-fire: ", pattern)
	match pattern:
		"beam-cross":
			var beams = []
			var beam = load("res://scenes/beam.tscn").instance()
			self.add_child(beam)
			beams.append(beam)
			beam.set_color(color)
			
			for i in range(1, 4):
				var other_beam: Spatial = beam.duplicate()
				other_beam.rotate_y(i * PI/2);
				self.add_child(other_beam)
				beams.append(other_beam)
			
			yield(get_tree().create_timer(1), "timeout")
			for node in beams:
				node.queue_free()


	pass
	