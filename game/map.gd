extends Node2D

func _ready():
	set_process_input(true)
	
func _input(event):
	if event.is_action_pressed("left_click"):

		var tileIndex = tile_index_from_mouse()
		for building in get_tree().get_nodes_in_group("map.buildings"):
			if building.located_at(tileIndex):
				building.clicked()
				break

func tile_index_from_mouse():
	var mouse_global_pos = get_global_mouse_position()
	# print_vec2("mouse_global_pos", mouse_global_pos)
	# TODO: Why is adding the offset needed here?
	return $buildings.world_to_map(mouse_global_pos + Vector2(0, 21))

func print_vec2(title, vec):
	print(title + ": x: " + str(vec.x) + ", y: " + str(vec.y)) 