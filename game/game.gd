extends Node2D

var fields = null

func _ready():
	var game = $save_game_loader.load_game("user://saves/game00.gam")
	print('Savegame parsed')
	
	var figure_data = $fields.field_data['animations']
	
	for ship in game['ships']:
		draw_ship(ship, figure_data)
	
	fields = get_field_dict(get_tree().get_nodes_in_group("fields"))
	
	for island in game['islands']:
		if island['diff'] == 0:
			for y in range(island['height']):
				for x in range(island['width']):
					var field = island['default_fields'][x][y]
					draw_field(island, x, y, field)
		
		for y in range(island['height']):
			for x in range(island['width']):
				var field = island['current_fields'][x][y]
				draw_field(island, x, y, field)

func draw_ship(ship, figure_data):
	var ship_node = preload("res://entities/ship/ship.tscn").instance()
	ship_node.begin(ship['type_name'], figure_data, ship['rotation'])
	ship_node.global_position = Vector2($map/buildings.map_to_world(ship['position']))

	$ships.add_child(ship_node)

func draw_field(island, x, y, field):
	var field_id = field['building']
	if field_id != 0xFFFF:
		assert(fields.has(field_id))
		fields[field_id].draw_field($map/buildings, Vector2(island['x'] + x, island['y'] + y), field['rotation'], field['ani'])

func get_field_dict(scenes):
	var dict = {}
	for scene in scenes:
		dict[scene.b_id] = scene
	return dict