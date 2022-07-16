extends Camera

var track_object: Spatial = null
var track_last_dist: float = 0
onready var starting_fov = self.fov

func bump(hit_dir: Vector3):
	hit_dir = hit_dir.normalized()
	
	self.translation += hit_dir/2;
	yield(get_tree().create_timer(0.05), "timeout")
	self.translation -= hit_dir;
	yield(get_tree().create_timer(rand_range(0.03, 0.08)), "timeout")
	self.translation += hit_dir;
	yield(get_tree().create_timer(rand_range(0.03, 0.08)), "timeout")
	self.translation -= hit_dir/2;

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
		self.get_parent().translation = lerp(self.get_parent().translation, track_object.global_transform.origin, 0.1)
		
		var new_dist = (track_object.global_transform.origin - self.global_transform.origin).length()
		self.fov = self.starting_fov + (track_last_dist - new_dist) * 2
		
		
		
