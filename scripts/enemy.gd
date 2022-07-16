extends KinematicBody

var moving_to: Vector3 = Vector3.INF
var cnt: float = 0
var randwalk_dist: float = 20
var can_fire = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	cnt += delta
	if cnt > 3:
		random_move()
		cnt = 0
	
	if Input.is_action_pressed("ui_accept") && can_fire:
		fire_bullet(get_node("/root/Arena/Player").translation, 20)
		can_fire = false
		yield(get_tree().create_timer(0.5), "timeout")
		can_fire = true
		

func _physics_process(delta):
	if moving_to != Vector3.INF:
		var diff = moving_to - self.translation

#		var move = lerp(self.translation, moving_to, 1)
		var move = (diff.normalized() * 5)
		if move.length() * delta > diff.length():
			move = diff
			moving_to = Vector3.INF
			
		
		move_and_slide(move, Vector3.UP, true)
		
#		self.translation += move;



		

func random_move():
	var target = get_node("/root/Arena/Player").translation;
	
	var dir = (target - self.translation).normalized()
	dir = dir.rotated(Vector3.UP, rand_range(-PI/4, PI/4))
	
	moving_to = self.translation + dir * rand_range(randwalk_dist/2, randwalk_dist)
	print("Moving from ", self.translation, "to ", moving_to)
		
#	var space_state = get_world().direct_space_state
#	while true:
#		var pos = self.translation + Vector3(rand_range(-30, 30), 0, rand_range(-30, 30))
#		if space_state.intersect_ray(self.translation + Vector3(0,0.1,0), pos + Vector3(0,0.1,0)):
#			continue
#		else:
#			moving_to = pos
#			break

func fire_bullet(target: Vector3, speed: float):
	var bullet_inst = load("res://scenes/bullet.tscn").instance()
	get_node("/root/Arena").add_child(bullet_inst)
	bullet_inst.translation = self.translation
	bullet_inst.move_towards(target, speed)
