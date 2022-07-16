extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_color(color: Color):
	$Vis/Vrt.set_modulate(color)
	$Vis/Hrz.set_modulate(color)

func _on_beam_hit(body):
	if body.name == "Enemy":
		body.queue_free()
