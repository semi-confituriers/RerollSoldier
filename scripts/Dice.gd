extends KinematicBody

export var speed = 0.4

var weapon_data = {
	"laser": {
		"texture_name": "die_laser_v1.png",
		#"func": funcref(self, boum) 
	},
	"bullet": {
		"texture_name": "die_bullet_v1.png",
		#"func": funcref(self, boum) 
	}
}

onready var pivot = $Pivot
onready var mesh = $Pivot/MeshInstance
onready var tween = $Tween

var current_weapon = null

var weapon_by_face = {
	1: null,
	2: null,
	3: null,
	4: null,
	5: null,
	6: null,	
}

func _ready():
	for face_id in range(1, 7):
		mesh.get_node(str(face_id)).visible = false
	_set_weapon_on_face(1, "laser")
	_set_weapon_on_face(2, "bullet")

func boum(): pass

func _physics_process(_delta):
	var forward = Vector3.FORWARD
	if Input.is_action_pressed("ui_up"):
		roll(forward)
	if Input.is_action_pressed("ui_down"):
		roll(-forward)
	if Input.is_action_pressed("ui_right"):
		roll(forward.cross(Vector3.UP))
	if Input.is_action_pressed("ui_left"):
		roll(-forward.cross(Vector3.UP))

func roll(dir):
	# Do nothing if we're currently rolling.
	if tween.is_active():
		return

	## Step 1: Offset the pivot
	pivot.translate(dir)
	mesh.global_translate(-dir)

	## Step 2: Animate the rotation
	var axis = dir.cross(Vector3.DOWN)
	tween.interpolate_property(pivot, "transform:basis",
			null, pivot.transform.basis.rotated(axis, PI/2),
			1/speed, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_all_completed")

	## Step3: Finalize movement and reverse the offset
	transform.origin += dir * 2
	var b = mesh.global_transform.basis  ## Save the rotation
	print(b)
	
	pivot.transform = Transform.IDENTITY
	mesh.transform.origin = Vector3(0, 1, 0)
	mesh.global_transform.basis = b  ## Apply the rotation

	current_weapon = weapon_by_face[get_current_up_face()]
	print(current_weapon)

func get_current_up_face(): 
	var y_max = -1000
	var upper_face = 0
	var y_pos_holder
	for i in range(1, 7):
		y_pos_holder = mesh.get_node(str(i)).global_transform.origin[1]
		if  y_pos_holder > y_max:
			upper_face = i
			y_max = y_pos_holder
	return upper_face

func _on_Tween_tween_step(object, key, elapsed, value):
	pivot.transform = pivot.transform.orthonormalized()

func _set_weapon_on_face(tile_id, weapon_id):
	var texture_path = weapon_data[weapon_id]["texture_name"]
	var face = mesh.get_node(str(tile_id))
	face.texture = load("res://assets/"+texture_path)
	face.visible = true
	weapon_by_face[tile_id] = weapon_id
