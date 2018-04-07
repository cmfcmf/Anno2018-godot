extends Node2D

func _ready():
	var game = $save_game_loader.load_game("res://imported/saves/game00.gam")
	
	var fields = get_field_dict(get_tree().get_nodes_in_group("fields"))
	var n_rotations = 1
	for island in game['islands']:
		for y in range(island['height']):
			for x in range(island['width']):
				var field = island['default_fields'][x][y]
				var field_id = field['building']
				if field_id != 0xFFFF:
					assert(fields.has(field_id))
					fields[field_id].draw_field($map/buildings, Vector2(island['x'] + x, island['y'] + y), field['rotation'], n_rotations, field['ani'])
				
		for y in range(island['height']):
			for x in range(island['width']):
				var field = island['current_fields'][x][y]
				var field_id = field['building']
				if field_id != 0xFFFF:
					assert(fields.has(field_id))
					fields[field_id].draw_field($map/buildings, Vector2(island['x'] + x, island['y'] + y), field['rotation'], n_rotations, field['ani'])
				
func get_field_dict(scenes):
	var dict = {}
	for scene in scenes:
		dict[scene.b_id] = scene
	return dict	