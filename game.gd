extends Node2D


var current_level_id = 0
var level_max = 1
onready var camera: Camera = $CameraNode/Camera

var level: Spatial = null
var player: KinematicBody = null

var maxHitpoint: int = 10;
var hitpoints: int = 10;

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
	$Gui/GameOver.visible = false
	
	var heartsContainer = $Gui/Hearts
	for child in heartsContainer.get_children():
		heartsContainer.remove_child(child)
	hitpoints = maxHitpoint
	for i in range(0, hitpoints):
		var heart = TextureRect.new();
		heart.texture = load("res://assets/heart_full.png")
		heartsContainer.add_child(heart)
		
	print("Loading level ", level_id)
	current_level_id = level_id
	var new_level_res = load("res://levels/level" + str(level_id) + ".tscn")
	var new_level = new_level_res.instance()
	new_level.name = "Level"
	
	for child in $LevelCont.get_children():
		$LevelCont.remove_child(child)
		child.queue_free()
	$LevelCont.add_child(new_level)
	
	# Gui updating
	$Gui/LevelBox/Level.text = "Level " + str(current_level_id) + " / " + str(level_max)
	$Gui/LevelBox/Prev.disabled = current_level_id == 1
	$Gui/LevelBox/Next.disabled = current_level_id == level_max
	
	self.level = new_level
	self.player = new_level.get_node("Player")
#	self.camera = new_level.get_node("CameraNode/Camera")
	self.camera.track(self.player)
	
	
func restart_level():
	load_level(current_level_id)
	
func prev_level():
	load_level(current_level_id - 1)
	
func next_level():
	if current_level_id == level_max:
		load_level(1)
	else:
		load_level(current_level_id + 1)


func change_hitpoints(diff: int):
	hitpoints += diff
	
	var i = 0
	for heart in $Gui/Hearts.get_children():
		if i < hitpoints:
			heart.texture = load("res://assets/heart_full.png")
		else:
			heart.texture = load("res://assets/heart_empty.png")
		i += 1
	
	if hitpoints <= 0:
		$Gui/GameOver.visible = true
		camera.track_object = null
		level.queue_free()
#		level.set_pause_mode(Node.PAUSE_MODE_STOP)
