extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	
	print(get_current_up_face())
	$dice.rotate_x(90)
	print(get_current_up_face())
	$dice.rotate_y(90)
	print(get_current_up_face())
	$dice.rotate_z(90)
	print(get_current_up_face())
	$dice.rotate_z(90)
	print(get_current_up_face())
	$dice.rotate_y(90)
	print(get_current_up_face())
	$dice.rotate_y(90)
	print(get_current_up_face())
	$dice.rotate_y(90)
	#print($"dice/1".global_transform.origin)
	#print($"dice/2".global_transform.origin)

func get_current_up_face(): 
	var y_max = -1000
	var upper_face = 0
	var y_pos_holder
	for i in range(1, 7):
		y_pos_holder = get_node("dice/"+str(i)).global_transform.origin[1]
		if  y_pos_holder > y_max:
			upper_face = i
			y_max = y_pos_holder
	return upper_face
	
