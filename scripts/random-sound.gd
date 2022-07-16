extends AudioStreamPlayer3D

export var prefix: String;
export var extension: String = ".wav";
var sounds = []

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for i in range(0, 1000):
		var res = load("res://" + prefix + str(i) + extension)
		if res == null:
			break
		sounds.append(res)
			

func play_rand():
	self.stream = sounds[randi() % len(sounds)]
	self.pitch_scale = rand_range(0.9, 1.1)
	self.play()
		

