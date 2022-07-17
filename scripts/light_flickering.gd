extends OmniLight

export var var_range: float = 0
export var var_energy: float = 0.1
export var frequency: float = 12

onready var orig_range = self.get_param(PARAM_RANGE)
onready var orig_energy = self.get_param(PARAM_ENERGY)

# Called when the node enters the scene tree for the first time.
func _ready():
	flicker()

func flicker():
	var new_range = orig_range * rand_range(1.0 - var_range, 1.0 + var_range)
	self.set_param(PARAM_RANGE, new_range)
	
	var new_energy = orig_energy * rand_range(1.0 - var_energy, 1.0 + var_energy)
	self.set_param(PARAM_ENERGY, new_energy)
	
	yield(get_tree().create_timer(1.0 / frequency), "timeout")
	flicker()
	
