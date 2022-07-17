extends Camera

var track_object: Spatial = null
var track_last_dist: float = 0
onready var starting_fov = self.fov

func bump(hit_dir: Vector3, force: float = 1):
	hit_dir = hit_dir.normalized()
	
	self.translation += force * hit_dir/2;
	yield(get_tree().create_timer(0.05), "timeout")
	self.translation -= force * hit_dir;
	yield(get_tree().create_timer(rand_range(0.03, 0.08)), "timeout")
	self.translation += force * hit_dir;
	yield(get_tree().create_timer(rand_range(0.03, 0.08)), "timeout")
	self.translation -= force * hit_dir/2;

func single_bump(hit_dir: Vector3, force: float = 1):
	hit_dir = hit_dir.normalized()
	
	self.translation += force * hit_dir/2;
	yield(get_tree().create_timer(0.05), "timeout")
	self.translation -= force * hit_dir;
	yield(get_tree().create_timer(rand_range(0.02, 0.05)), "timeout")
	self.translation += force * hit_dir/2;

func kick_out():
	self.fov += 1
	yield(get_tree().create_timer(rand_range(0.1, 0.2)), "timeout")
	self.fov -= 1
	
func track(obj: Spatial):
	self.track_object = obj
	self.get_parent().translation = track_object.global_transform.origin
	self.track_last_dist = (track_object.global_transform.origin - self.global_transform.origin).length()

func _process(delta):
	if track_object != null:
#		self.get_parent().translation = track_object.global_transform.origin
		self.get_parent().translation = lerp(self.get_parent().translation, track_object.global_transform.origin, 0.1)
		
#	if track_object != null:
#		var mult = 2.0
#		var new_dist = (track_object.global_transform.origin - self.global_transform.origin).length()
#		if track_last_dist - new_dist > 0:
#			mult += (track_last_dist - new_dist) * 100
#			if delta * mult > 0.9:
#				mult = 0.9 / delta
#
#		self.get_parent().global_transform.origin = lerp(
#			self.get_parent().global_transform.origin,
#			track_object.global_transform.origin, delta * mult)
##		self.get_parent().translation = lerp(self.get_parent().translation, track_object.global_transform.origin, 0.1)
#
##		self.fov = self.starting_fov + (track_last_dist - new_dist) * 2
#
#		track_last_dist = new_dist;
		
		
		
