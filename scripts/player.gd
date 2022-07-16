extends KinematicBody

# How fast the player moves in meters per second.
export var speed = 14
# The downward acceleration when in the air, in meters per second squared.
export var fall_acceleration = 75

var velocity = Vector3.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	# We create a local variable to store the input direction.
	var direction = Vector3.ZERO

	# We check for each move input and update the direction accordingly.
	if Input.is_action_pressed("move_right"):
		print("move_right")
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		print("move_left")
		direction.x -= 1
	if Input.is_action_pressed("move_down"):
		# Notice how we are working with the vector's x and z axes.
		# In 3D, the XZ plane is the ground plane.
		print("move_down")
		direction.z += 1
	if Input.is_action_pressed("move_up"):
		print("move_up")
		direction.z -= 1
		
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
