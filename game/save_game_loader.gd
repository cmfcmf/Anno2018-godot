extends Node

func load_game(game_path):
	var game_file = File.new()
	assert(game_file.open(game_path, File.READ) == OK)
	
	var islands = []
	var types = {}
	while not game_file.eof_reached():
		var block = {}
		block['type'] = game_file.get_buffer(16).get_string_from_ascii()
		block['length'] = game_file.get_32()
		
		if block['type'] == 'INSEL5':
			islands.append(parse_island(game_file))
			# TODO: Do something if diff is zero.
		elif block['type'] == 'INSELHAUS':
			islands.append(raster_island(islands.pop_back(), block['length'], game_file))
		else:
			game_file.get_buffer(block['length'])
			
		types[block['type']] = true

	game_file.close()
	
	return {
		'islands': islands
	}

func raster_island(island, data_len, data):
	var fields = []
	for x in range(island['width']):
		fields.append([])
		for y in range(island['height']):
			fields[x].append({
				'building': 0xFFFF,
				'x': 0, # x relative to the building's origin
				'y': 0, # y relative to the building's origin
			})
			
	for i in range(data_len / 8):
		var field = parse_island_field(data)
		assert(field.x < island['width'])
		assert(field.y < island['height'])
		
		var building_id = field['building']
		if building_id != 0xFFFF:
			# TODO Take building size and rotation into account
			
			fields[(field['x'])][(field['y'])] = field
			# x and y are actually relative to the current building.
			fields[(field['x'])][(field['y'])]['x'] = 0
			fields[(field['x'])][(field['y'])]['y'] = 0
		else:
			fields[(field['x'])][(field['y'])] = field
			# x and y are actually relative to the current building.
			fields[(field['x'])][(field['y'])]['x'] = 0
			fields[(field['x'])][(field['y'])]['y'] = 0
	
	island['fields'] = fields
	
	return island

func parse_island_field(data):
	var island_field = {}
	island_field['building'] = data.get_16() + 20000
	# x and y are relative to the island's origin
	island_field['x'] = data.get_8()
	island_field['y'] = data.get_8()
	
	var bits = data.get_32()
	
	# TODO: Verify bitmasks are correct
	island_field['rotation'] = (bits & 3)
	island_field['ani']      = (bits >> 2)  & 0xF
	island_field['_']        = (bits >> 6)  & 0xFF
	island_field['status']   = (bits >> 14) & 7
	island_field['random']   = (bits >> 17) & 0x1F
	island_field['player']   = (bits >> 22) & 7
	island_field['_']        = (bits >> 25) & 0x7F
	
	return island_field
	
func parse_island(data):
	var island = {}
	island['num'] = data.get_8()
	island['width'] = data.get_8()
	island['height'] = data.get_8()
	island['_'] = data.get_8()
	island['x'] = data.get_16()
	island['y'] = data.get_16()
	island['_'] = data.get_16()
	island['_'] = data.get_16()
	island['_'] = data.get_buffer(14)
	island['num_ore_locations'] = data.get_8()
	island['fertility_discovered'] = data.get_8()
	island['ore_locations'] = [parse_ore_location(data), parse_ore_location(data)]
	island['_'] = data.get_buffer(48)
	island['fertility'] = data.get_8()
	island['_'] = data.get_8()
	island['_'] = data.get_16()
	island['num_base_island'] = data.get_16()
	island['_'] = data.get_16()
	island['is_south'] = data.get_8()
	island['diff'] = data.get_8()
	island['_'] = data.get_buffer(14)
	island['fields'] = []
	return island
	
func parse_ore_location(data):
	var ore_location = {}
	ore_location['type'] = data.get_8()
	ore_location['x'] = data.get_8()
	ore_location['y'] = data.get_8()
	ore_location['discovered'] = data.get_8()
	ore_location['unknown'] = data.get_32()
	return ore_location
