extends KinematicBody

export var speed = 0.4
const STAND_UP_OFFSET = 0.7

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
onready var leg = $leg

export var AFTER_ROLL_DELAY = 0.3
var roll_counter = 0

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
	set_weapon_on_face(1, "laser")
	set_weapon_on_face(2, "bullet")

	deploy_die()

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
	if is_rolling(): return

	retract_die()

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
	pivot.transform = Transform.IDENTITY
	mesh.transform.origin = Vector3(0, 1, 0)
	mesh.global_transform.basis = b  ## Apply the rotation
	
	current_weapon = weapon_by_face[get_current_up_face()]
	
	roll_counter += 1 
	yield(get_tree().create_timer(AFTER_ROLL_DELAY), "timeout")
	roll_counter -= 1
	if roll_counter == 0: 
		deploy_die()

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

func set_weapon_on_face(tile_id, weapon_id):
	var texture_path = weapon_data[weapon_id]["texture_name"]
	var face = mesh.get_node(str(tile_id))
	face.texture = load("res://assets/"+texture_path)
	face.visible = true
	weapon_by_face[tile_id] = weapon_id

func is_rolling(): 
	return tween.is_active()

func deploy_die():
	leg.visible = true
	pivot.translate(Vector3(0, STAND_UP_OFFSET, 0))
	pass

func retract_die():
	leg.visible = false
	pass
	