extends KinematicBody

var moving_to: Vector3 = Vector3.INF
var cnt: float = 0
var next_cnt: float = 3
var randwalk_dist: float = 20
var can_fire = true

enum MobType {
	Shooter, # Walks randomly, shoots bullets
	Bull, # Moves towards the player, hits on collision
	Shaker, # Smash the player and change its weapon
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	cnt += delta
	if cnt > next_cnt:
		random_move()
		fire_bullet(get_node("/root/Game/LevelCont/Level/Player").translation, 20)
		cnt = 0
		next_cnt = rand_range(3, 4)
		
	
#	if Input.is_action_pressed("ui_accept") && can_fire:
#		fire_bullet(get_node("/root/Arena/Player").translation, 20)
#		can_fire = false
#		yield(get_tree().create_timer(0.5), "timeout")
#		can_fire = true
		

func _physics_process(delta):
	if moving_to != Vector3.INF:
		var diff = moving_to - self.translation

#		var move = lerp(self.translation, moving_to, 1)
		var move = (diff.normalized() * 5)
		if move.length() * delta > diff.length():
			move = diff
			moving_to = Vector3.INF
			
		
		move = move_and_slide(move, Vector3.UP, true)
		
#		self.translation += move;



		

func random_move():
	var target = get_node("/root/Game/LevelCont/Level/Player").translation;
	
	var target_vect = target - self.translation;
	var dir = Vector3.INF
	if target_vect.length() < 5:
		dir = (self.translation - target).normalized().rotated(Vector3.UP, rand_range(-PI/2, PI/2))
	else:
		dir = target_vect.normalized().rotated(Vector3.UP, rand_range(-PI/4, PI/4))
	
	moving_to = self.translation + dir * rand_range(randwalk_dist/2, randwalk_dist)
	moving_to.y = 0
		
#	var space_state = get_world().direct_space_state
#	while true:
#		var pos = self.translation + Vector3(rand_range(-30, 30), 0, rand_range(-30, 30))
#		if space_state.intersect_ray(self.translation + Vector3(0,0.1,0), pos + Vector3(0,0.1,0)):
#			continue
#		else:
#			moving_to = pos
#			break

func fire_bullet(target: Vector3, speed: float):
	print("enemy-fire: ", self.translation, "->", target)
	var bullet = load("res://scenes/bullet.tscn").instance()
	get_node("/root/Game/LevelCont/Level").add_child(bullet)
	bullet.fire(self.translation, target, speed, true) 

# Called by bullet.gd
func on_bullet_hit(_hit_dir: Vector3):
	self.queue_free()
