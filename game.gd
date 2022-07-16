extends Node2D


var current_level_id = 0
var level_max = 1

func _ready():
	load_level(1)
	
	$Gui/LevelBox/Prev.connect("pressed", self, "prev_level")
	$Gui/LevelBox/Next.connect("pressed", self, "next_level")
	$Gui/LevelBox/Restart.connect("pressed", self, "restart_level")

func set_controls(enabled):
	if enabled:
		$Gui/LevelBox/Prev.show()
		$Gui/LevelBox/Next.show()
		$Gui/LevelBox/Restart.show()
	else:
		$Gui/LevelBox/Prev.hide()
		$Gui/LevelBox/Next.hide()
		$Gui/LevelBox/Restart.hide()

func load_level(level_id: int):
	print("Loading level ", level_id)
	current_level_id = level_id
	var new_level_res = load("res://levels/level" + str(level_id) + ".tscn")
	var new_level = new_level_res.instance()
	new_level.name = "Level"
	
	for child in $LevelCont.get_children():
		$LevelCont.remove_child(child)
	$LevelCont.add_child(new_level)
	
	# Gui updating
	$Gui/LevelBox/Level.text = "Level " + str(current_level_id) + " / " + str(level_max)
	$Gui/LevelBox/Prev.disabled = current_level_id == 1
	$Gui/LevelBox/Next.disabled = current_level_id == level_max
	
	
func restart_level():
	load_level(current_level_id)
	
func prev_level():
	load_level(current_level_id - 1)
	
func next_level():
	if current_level_id == level_max:
		load_level(1)
	else:
		load_level(current_level_id + 1)

