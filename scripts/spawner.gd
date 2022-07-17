extends Node

export var mob_list = [
	[1.0, [ [1, "shooter"], [1, "shooter"] ] ],
	[5.0, [ [1, "bomber"] ] ],
	[10, [ [2, "bomber"], [1, "bomber"], [1, "shooter"]] ],
	[20, [ [2, "bomber"], [1, "bomber"], [1, "shooter"]] ],
	[30, [ [2, "shooter"], [1, "shooter"], [1, "shooter"]] ],
	[40, [ [2, "bomber"], [1, "shooter"], [1, "shooter"]] ],
	[60, [ [2, "bomber"], [3, "shooter"], [1, "shooter"]] ],
	[80, [ [1, "shooter"], [3, "shooter"], [1, "shooter"]] ],
	[100, [ [4, "bomber"], [1, "bomber"], [1, "bomber"]] ],
	[120, [ [3, "shooter"], [5, "shooter"], [4, "bomber"]] ],
]
export var disabled: bool = false

var mob_scene = load("res://scenes/enemy.tscn")
var spawn_finished = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if !disabled:
		yield(get_tree().create_timer(0.5), "timeout")
		spawn()

func spawn():
	var spawn_points: Array = $SpawnPoints.get_children()
	var curr_time = 0.0
	for l in mob_list:
		var wait = l[0] - curr_time
		
		yield(get_tree().create_timer(wait), "timeout")
		curr_time += wait
		
		for to_spawn in l[1]:
			var cnt = to_spawn[0]
			var mob_type = to_spawn[1]
			
	
			for _i in range(0, cnt):
				var spawn_point = spawn_points[randi() % spawn_points.size()]
				
				var mob = mob_scene.instance()
				mob.set_enemy_type(mob_type)
				
				get_node("/root/Game/LevelCont/Level/Enemies").add_child(mob)
				
				mob.set_translation(
					spawn_point.get_translation()
					 + Vector3(rand_range(-1, 1), 0, rand_range(-1, 1))
				)
	spawn_finished = true

func _process(delta):
	print(is_level_finished())
	pass

func is_level_finished():
	if not spawn_finished:
		return false	
	if len(get_node("/root/Game/LevelCont/Level/Enemies").get_children()) == 0:
		return true
	else:
		return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
