extends Camera


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
