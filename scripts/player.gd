extends KinematicBody

var walk_speed: float = 6
var roll_speed: float = 12
const AFTER_ROLL_DELAY: float = 0.1
const fall_acceleration: float = 4.0
const recover_time: float = 1.0


var weapon_data = {
	"laser": {
		"texture_name": "label_blue.png",
		"arm_mesh": "arm_laser"
	},
	"bullet": {
		"texture_name": "label_green.png",
		"arm_mesh": "arm_bullet"
	}, 
	"bullet_mono": {
		"texture_name": "label_yellow.png",
		"arm_mesh": "arm_bullet_mono"
	}
}

onready var pivot = $Pivot
onready var mesh = $Pivot/MeshInstance
onready var tween = $Tween
onready var leg = $parts/leg

const STAND_UP_OFFSET = 0.7

var deploy_counter = 0
var invincible = false
var can_move = true

var current_weapon = null
var current_arm_mesh = null
var current_dir = Vector3.FORWARD

var weapon_by_face = {
	1: null,
	2: null,
	3: null,
	4: null,
	5: null,
	6: null,	
}

var current_speed = Vector3.ZERO
var can_fire = true

# Called when the node enters the scene tree for the first time.
func _ready():
	for face_id in range(1, 7):
		mesh.get_node(str(face_id)).visible = false

	for weapon_id in weapon_data:
		get_weapon_arm_mesh_from_id(weapon_id).visible = false

#	$parts/misc.translate(Vector3(0, STAND_UP_OFFSET, 0))
#	$parts/arm_weapon.translate(Vector3(0, STAND_UP_OFFSET, 0))

	set_weapon_on_face(1, "laser")
	set_weapon_on_face(2, "bullet")
	set_weapon_on_face(3, "bullet_mono")

	deploy_die(Vector3.FORWARD, false)

func _physics_process(delta):
	if !can_move:
		return
		
	if Input.is_action_pressed("crouch"):
		if can_move:
			# Roll on a sides
			var forward = Vector3.FORWARD
			if Input.is_action_pressed("move_up"):
				roll(forward)
			elif Input.is_action_pressed("move_down"):
				roll(-forward)
			elif Input.is_action_pressed("move_right"):
				roll(forward.cross(Vector3.UP))
			elif Input.is_action_pressed("move_left"):
				roll(-forward.cross(Vector3.UP))
	elif leg.visible:
		# Slow and precise
		var direction = Vector3.ZERO
		if Input.is_action_pressed("move_right"):
			direction.x += 1
		if Input.is_action_pressed("move_left"):
			direction.x -= 1
		if Input.is_action_pressed("move_down"):
			direction.z += 1
		if Input.is_action_pressed("move_up"):
			direction.z -= 1
		
		if direction != Vector3.ZERO:
			direction = direction.normalized()
			$AnimationPlayer.play("walk")
		else:
			if $AnimationPlayer.get_current_animation() == "walk":
				var length = $AnimationPlayer.get_animation("walk").get_length()
				$AnimationPlayer.seek(length)
#				$AnimationPlayer.stop()
		
		current_speed.x = direction.x * walk_speed
		current_speed.z = direction.z * walk_speed
		current_speed.y -= fall_acceleration * delta
		
		# Moving the character
		current_speed = move_and_slide(current_speed, Vector3.UP)
		

		if Input.is_action_pressed("fire") && can_fire && leg.visible:
			var weapon = weapon_by_face[get_current_up_face()]
			if weapon != null :
				fire(weapon)

# Called by bullet.gd
func on_hit(_dmg: int, hit_dir: Vector3):
	if self.invincible:
		return
		
	var impact: Spatial = load("res://res/vfx/impact.tscn").instance()
	get_node("/root/Game").level.add_child(impact)
	impact.global_transform.origin = self.global_transform.origin - hit_dir + Vector3.UP
		
		
	if is_rolling():
#		can_move = false
		yield(tween, "tween_all_completed")
#		yield(get_tree().create_timer(0.2), "timeout")
#		can_move = true
		
	var game = get_node("/root/Game")
	game.camera.bump(hit_dir)
	game.camera.kick_out()
	
	throw_up(recover_time)
	
func fire(type: String, color: Color = Color.red):
	print("player-fire: ", type)
	can_fire = false
	var weapon_node: Spatial = get_node("parts/arm_weapon/arm_" + type)
	
	var src_pos = self.global_transform.origin
	var src_node = weapon_node.get_node("src")
	if src_node != null:
		src_pos = src_node.global_transform.origin
	
	match type:
		"laser":
			var beams = []
			var beam: Spatial = load("res://scenes/beam.tscn").instance()
			beam.set_color(Color.blue)
			self.add_child(beam)
			beam.translation = src_pos - self.global_transform.origin
			
			var angle = Vector3.FORWARD.signed_angle_to(current_dir, Vector3.UP)
			beam.rotate_y(angle)
			
#			beam.look_at(self.translation + current_dir, Vector3.UP)
			
			beams.append(beam)
			var coll_area: Area = beam.get_node("Area")
			coll_area.set_collision_mask_bit(4, false) # Disable coll with player
			
#			for i in range(1, 4):
#				var other_beam: Spatial = beam.duplicate()
#				other_beam.rotate_y(i * PI/2);
#				self.add_child(other_beam)
#				beams.append(other_beam)

			$WeaponAnim.stop()
			$WeaponAnim.play("fire-laser")
			
			self.move_and_collide(-current_dir * 0.5)
#
			yield(get_tree().create_timer(0.2), "timeout")
			for node in beams:
				node.queue_free()
				
			yield(get_tree().create_timer(0.5), "timeout")
			can_fire = true
		"bullet":
			for i in range(0, 3):
				
				var this_dir;
				match i:
					0: this_dir = current_dir
					1: this_dir = current_dir.rotated(Vector3.UP, PI/2)
					2: this_dir = current_dir.rotated(Vector3.UP, -PI/2)
				
				var bullet: Spatial = load("res://scenes/bullet.tscn").instance()
				get_node("/root/Game/LevelCont/Level").add_child(bullet)
				
				var from = src_pos
#				var from = self.global_transform.origin
				bullet.fire(from, from + this_dir, 40, false)
			
			$WeaponAnim.stop()
			$WeaponAnim.play("fire-bullet")
			
			self.move_and_collide(-current_dir)
			
			yield(get_tree().create_timer(0.2), "timeout")
			can_fire = true
		"bullet_mono":
			print("nonn")
		"bomb":
#			var dir = Vector3.FORWARD # TODO: use model otientation
#			var target = self.translation + dir * 5.0
			
			var aoe = load("res://scenes/aoe.tscn").instance()
			get_node("/root/Game/LevelCont/Level").add_child(aoe)
#			aoe.translation = target
			aoe.translation = self.translation
			aoe.configure(4, 1, Color.blue, false);
			
			yield(get_tree().create_timer(2), "timeout")
			can_fire = true
			
		_:
			printerr("No attack type ", type)
			can_fire = true
			

func boum(): 
	pass
	
func roll(dir: Vector3):
	
	# Do nothing if we're currently rolling.
	if is_rolling(): return
	
	var ray_start = self.global_transform.origin
	var ray_end = ray_start + dir * 3
	var intersect = get_world().direct_space_state.intersect_ray(ray_start, ray_end, [], 0b001)
	if intersect:
		return

	retract_die()

	## Step 1: Offset the pivot
	pivot.translate(dir)
	mesh.global_translate(-dir)

	deploy_counter += 1
	
	## Step 2: Animate the rotation
	var axis = dir.cross(Vector3.DOWN)
	tween.interpolate_property(pivot, "transform:basis",
			null, pivot.transform.basis.rotated(axis, PI/2),
			1/roll_speed, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.interpolate_property(self, "translation",
			null, self.translation + dir * 2,
			1/roll_speed, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.interpolate_property(pivot, "translation",
			null, pivot.translation - dir * 2,
			1/roll_speed, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_all_completed")
	
	$StepSound.play_rand()

	## Step3: Finalize movement and reverse the offset
#	transform.origin += dir * 2
	var b = mesh.global_transform.basis  ## Save the rotation
	pivot.transform = Transform.IDENTITY
	mesh.transform.origin = Vector3(0, 1, 0)
	mesh.global_transform.basis = b  ## Apply the rotation
	
	current_dir = -dir
	
	yield(get_tree().create_timer(AFTER_ROLL_DELAY), "timeout")
	deploy_counter -= 1
	if deploy_counter == 0:
		deploy_die(current_dir)

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

func _on_Tween_tween_step(_object, _key, _elapsed, _value):
	pivot.transform = pivot.transform.orthonormalized()

func set_weapon_on_face(tile_id, weapon_id):
	var texture_path = weapon_data[weapon_id]["texture_name"]
	var face = mesh.get_node(str(tile_id))
	face.texture = load("res://assets/"+texture_path)
	face.visible = true
	weapon_by_face[tile_id] = weapon_id

func unset_weapon_on_face(tile_id): 
	if weapon_by_face[tile_id] == null: return
	var face = mesh.get_node(str(tile_id))
	face.visible = false
	weapon_by_face[tile_id] = null	

func get_weapon_arm_mesh_from_id(weapon_id): 
	if weapon_id == null: 
		return $parts/arm_weapon/arm_white_flag
	return $parts/arm_weapon.get_node(weapon_data[weapon_id]["arm_mesh"])

func get_current_weapon_emission_source():
	if not current_weapon:
		return null
	var weapon_mesh = get_weapon_arm_mesh_from_id(current_weapon)
	return weapon_mesh.get_node("src")

func is_rolling(): 
	return tween.is_active()

func deploy_die(dir, raise: bool = true):
	
	var angle = Vector3.FORWARD.signed_angle_to(dir, Vector3.UP)

	$parts.set_identity()
	$parts.rotate_y(angle)

	leg.visible = true
	if raise:
		pivot.translate(Vector3(0, STAND_UP_OFFSET, 0))
	current_weapon = weapon_by_face[get_current_up_face()]
	current_arm_mesh = get_weapon_arm_mesh_from_id(current_weapon)
	current_arm_mesh.visible = true
	
	$parts/misc.visible = true
	
	var game = get_node("/root/Game")
	game.camera.single_bump(Vector3.UP, 0.5)

func retract_die():
	leg.visible = false
	current_arm_mesh.visible = false
	$parts/misc.visible = false
	

func throw_up(invuln_time: float):
	self.invincible = true
	self.can_move = false
	deploy_counter += 1
	
	retract_die()
	$AnimationPlayer.play("jump")
	var saved_pivot_transform = pivot.transform;
	
	var saved_collision_layer = self.collision_layer
	self.collision_layer = 0
	
	yield($AnimationPlayer, "animation_finished")
	
	$WeaponSounds.stream = load("res://sounds/dice-fall.wav")
	$WeaponSounds.play()
	var game = get_node("/root/Game")
	game.camera.bump(Vector3.UP, 0.1)
	
	
	var deploy_dir;
	match randi() % 4:
		0: deploy_dir = Vector3.FORWARD
		1: deploy_dir = Vector3.RIGHT
		2: deploy_dir = Vector3.BACK
		3: deploy_dir = Vector3.LEFT
		
	match randi() % 6:
		0: mesh.global_transform.basis = pivot.transform.basis.rotated(Vector3.FORWARD, 0)
		1: mesh.global_transform.basis = pivot.transform.basis.rotated(Vector3.FORWARD, PI/2)
		2: mesh.global_transform.basis = pivot.transform.basis.rotated(Vector3.FORWARD, -PI/2)
		3: mesh.global_transform.basis = pivot.transform.basis.rotated(Vector3.FORWARD, PI)
		4: mesh.global_transform.basis = pivot.transform.basis.rotated(Vector3.LEFT, PI/2)
		5: mesh.global_transform.basis = pivot.transform.basis.rotated(Vector3.LEFT, -PI/2)

	deploy_counter -= 1
	if deploy_counter == 0:
		deploy_die(deploy_dir, false)
	
	self.can_move = true
	yield(get_tree().create_timer(invuln_time), "timeout")
	
	self.collision_layer = saved_collision_layer
	self.invincible = false
	
	
	
