extends Spatial

var weapons_description = {
	"weapon_1": {
		"attack_anim": funcref(self, "you_may_fire_when_ready"), 
	},
	"weapon_2": {
		"attack_anim": funcref(self, "you_may_fire_when_ready"), 
	}
}
var equiped_weapons = []

const WEAPON_TILE_OFFSET = 0.01 

func you_may_fire_when_ready(): 
	pass

func _ready():
	
	# hidiong all weapons tiles. 
	for weapon_id in weapons_description:
		get_node(weapon_id).visible = false
	
	# test
	equip_weapon("weapon_2")
	print(get_current_weapon())

func equip_weapon(weapon_id):	
	
	# unequip current weapon if one.
	var current_weapon_id = get_current_weapon()
	if current_weapon_id !=null: 
		unequip_weapon(current_weapon_id)
	
	# positioning weapon tile on top of cube.
	var refCube_pos = $refCube.global_transform.origin
	var weapon_node = get_node(weapon_id)
	
	weapon_node.global_transform.origin = Vector3(
		refCube_pos[0],
		refCube_pos[1]+ 0.5 + WEAPON_TILE_OFFSET, # assuming cube size is 1.
		refCube_pos[2]
	)
	
	# handling reference and vis.
	weapon_node.get_parent().remove_child(weapon_node)
	$refCube.add_child(weapon_node)
	equiped_weapons.append(weapon_id)
	weapon_node.visible = true

func get_current_weapon():
	
	# checking which tile is on top of cube.
	var refCube_pos = $refCube.global_transform.origin[1]
	for weapon_id in equiped_weapons:
		var pos = $refCube.get_node(weapon_id).global_transform.origin[1]
		if abs(refCube_pos + 0.5 + WEAPON_TILE_OFFSET - pos) < 0.01:
			return weapon_id
	return null

func unequip_weapon(weapon_id): 
	#TODO 
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
