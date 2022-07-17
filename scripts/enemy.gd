extends KinematicBody

var moving_to: Vector3 = Vector3.INF
var cnt: float = 0
var next_cnt: float = 3
var randwalk_dist: float = 20
var can_fire = true
export var hitpoints = 2

onready var orig_scale = self.scale

var mob_data = {
	"ball": {
		"mesh": "ball"
	},
	"shooter": {
		"mesh": "card"
	},
	"bomber": {
		"mesh": "stack"
	}
}

var current_type = null
var default_type = "shooter"

# Called when the node enters the scene tree for the first time.
func _ready():
	#set_enemy_type(default_type)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player = get_node("/root/Game/LevelCont/Level/Player")
	cnt += delta
	if cnt > next_cnt:
		random_move()
		match current_type:
			"shooter":
				fire_bullet(player.translation, 15)
			"bomber":
				fire_mortier(player.translation, 2)
		cnt = 0
		next_cnt = rand_range(3, 4)
	look_at(player.translation, Vector3.UP)

func _physics_process(delta):
	if moving_to != Vector3.INF:
		var diff = moving_to - self.translation
		var move = (diff.normalized() * 5)
		if move.length() * delta > diff.length():
			move = diff
			moving_to = Vector3.INF
		move = move_and_slide(move, Vector3.UP, true)

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

func fire_bullet(target: Vector3, speed: float):
#	print("enemy-fire: ", self.translation, "->", target)
	var bullet = load("res://scenes/bullet.tscn").instance()
	get_node("/root/Game/LevelCont/Level").add_child(bullet)
	
	#var from = self.translation
	var from = get_mesh_emission_src(current_type).global_transform.origin
#	from.y = 1.0
	bullet.fire(from, target, speed, true, "red")

func fire_mortier(target: Vector3, speed: float):
	var mortier = load("res://scenes/mortier.tscn").instance()
	get_node("/root/Game/LevelCont/Level").add_child(mortier)

	var from = get_mesh_emission_src(current_type).global_transform.origin

	mortier.fire(from, target, speed)
# Called by bullet.gd
func on_hit(dmg: int, hit_dir: Vector3):

	self.scale = Vector3(0.8, 0.8, 0.8)
	
	var impact: Spatial = load("res://res/vfx/impact.tscn").instance()
	get_node("/root/Game").level.add_child(impact)
	impact.global_transform.origin = self.global_transform.origin - hit_dir + Vector3.UP

	hitpoints -= dmg
	if hitpoints > 0:
		$HitSound.play()
		yield(get_tree().create_timer(0.4), "timeout")
		self.scale = orig_scale
	else:
		get_node("/root/Game").player.get_node("DeathSound").play()
#		var new_own = get_node("/root/Game").level
#		var deathsound = $DeathSound
#		deathsound.set_owner(new_own)
#		new_own.add_child(deathsound)
#		self.remove_child(deathsound)
#		deathsound.play()
		self.queue_free()
	
func set_enemy_type(enemy_type_id):
	print(enemy_type_id)
	if current_type != null:
		get_mesh_by_enemy_type(current_type).visible = false
	get_mesh_by_enemy_type(enemy_type_id).visible = true
	current_type = enemy_type_id
	
func get_mesh_by_enemy_type(enemy_type_id):
	var node_name = mob_data[enemy_type_id]["mesh"]
	return $enemy_meshes.get_node(node_name)

func get_mesh_emission_src(enemy_type_id):
	var node_name = mob_data[enemy_type_id]["mesh"]
	var node = $enemy_meshes.get_node(node_name)
	return node.get_node("src")
