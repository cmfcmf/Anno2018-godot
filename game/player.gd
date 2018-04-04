extends Node

var money = 10000
var color = Color("#FFFF00")

var current_building = null

onready var map = $"../../map"
onready var tilemap_buildings = $"../../map/buildings"
onready var tilemap_temp = $"../../map/temp"

func _ready():
	set_process_input(true)
	set_process(true)

func _input(event):
	if current_building != null:
		if event.is_action_pressed("right_click"):
			stop_building()
		elif event.is_action_pressed("left_click"):
			current_building.build(tilemap_buildings, map.tile_index_from_mouse())
			#stop_building()

func _process(delta):
	if current_building != null:
		tilemap_temp.clear()
		current_building.preview(tilemap_temp, map.tile_index_from_mouse())
	
func start_building(building):
	print("Oh noes! Player selected a building")
	current_building = building

func stop_building():
	print("Oh noes! Player DESELECTED a building")
	current_building = null
	tilemap_temp.clear()