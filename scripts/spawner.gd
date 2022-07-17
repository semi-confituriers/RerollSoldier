extends Node

export var mob_list = [
	[1.0, [ [1, "shooter"], [1, "shooter"] ] ],
	[5.0, [ [1, "bomber"] ] ],
	[10, [ [2, "bomber"], [1, "bomber"], [3, "shooter"]] ],
]
export var disabled: bool = false

var mob_scene = load("res://scenes/enemy.tscn")

var mob_config = {
	"red": {
		"scene": "res://scenes/enemy.tscn",
	},
	"blue": {
		"scene": "res://scenes/enemy.tscn"
	},
}


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

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
