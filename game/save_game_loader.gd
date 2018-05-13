# The savegame datastructure was reverse engineered by Benedikt Freisen
# as part of the 'mdcii-engine' project and released under GPLv2+.
# https://github.com/roybaer/mdcii-engine

extends Node

const SHIP_TYPES = {
	0x15: 'HANDEL1',
	0x17: 'HANDEL2',
	0x19: 'KRIEG1',
	0x1B: 'KRIEG2',
	0x1D: 'HANDLER',
	0x1F: 'PIRAT',
	0x25: 'HANDLER', # TODO, Why is this duplicated?
}

func load_game(game_path):
	var game_file = File.new()
	assert(game_file.open(game_path, File.READ) == OK)
	
	var islands = []
	var ships = []
	var types = {}
	while not game_file.eof_reached():
		var block = read_block(game_file)
		var old_position = game_file.get_position()
		
		if block['type'] == 'INSEL5':
			var island = parse_island(game_file)
			
			# TODO: What exactly does diff stand for?
			if island['diff'] == 0:
				var island_file_path = get_island_file_path(island)
				var island_file = File.new()
				assert(island_file.open(island_file_path, File.READ) == OK)
				
				var island_basis_block = read_block(island_file)
				discard_block(island_basis_block, island_file)
				
				var island_buildings_block = read_block(island_file)
				island['default_fields'] = parse_island_buildings(island, island_buildings_block, island_file)
				island_file.close()
			
			islands.append(island)

		elif block['type'] == 'INSELHAUS':
			var island = islands.pop_back()
			island['current_fields'] = parse_island_buildings(island, block, game_file)
			islands.append(island)
		elif block['type'] == 'SHIP4':
			assert(ships.size() == 0)
			ships = parse_ships(block, game_file)
		else:
			discard_block(block, game_file)
		
		assert(game_file.get_position() == old_position + block['length'])
		
		types[block['type']] = true

	game_file.close()
	
	print(types)
	
	return {
		'islands': islands,
		'ships': ships,
	}

func parse_ships(block, game_file):
	var ships = []
	var start_pos = game_file.get_position()
	while game_file.get_position() < start_pos + block['length']:
		ships.append(parse_ship(game_file))
	return ships

func parse_ship(data):
	var ship = {}
	ship['name'] = data.get_buffer(28).get_string_from_ascii()
	ship['position'] = Vector2(
		data.get_16(),
		data.get_16()
	)
	ship['_1'] = data.get_buffer(3 * 4)
	ship['course_from'] = data.get_32()
	ship['course_to'] = data.get_32()
	ship['course_current'] = data.get_32()
	ship['_2'] = data.get_32()
	ship['hp'] = data.get_16()
	ship['_3'] = data.get_32()
	ship['canons'] = data.get_8()
	ship['flags'] = data.get_8()
	ship['sell_price'] = data.get_16()
	ship['id'] = data.get_16()
	ship['type'] = data.get_16()
	ship['_4'] = data.get_8()
	ship['player'] = data.get_8()
	ship['_5'] = data.get_32()
	ship['rotation'] = data.get_16()
	ship['trade_stops'] = parse_trade_stops(data, 8)
	ship['_6'] = data.get_16()
	ship['cargo'] = parse_goods(data, 8)
	ship['type_name'] = SHIP_TYPES[ship['type']]
	return ship

func parse_trade_stops(data, n):
	var trade_stops = []
	for i in range(n):
		trade_stops.append({
			'id': data.get_8(),
			'kontor_id': data.get_8(),
			'_1': data.get_16(),
			'goods': parse_goods(data, 2),
			'_2': data.get_buffer(16),
		})
	return trade_stops

func parse_goods(data, n):
	var cargo = []
	for i in range(n):
		cargo.append({
			'good_id': data.get_16(),
			'amount': data.get_16(),
			'action': data.get_32(), # 0 == 'load', 1 == 'unload'
		})
	return cargo


func parse_island_buildings(island, block, data):
	var data_len = block['length']

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
	
	return fields

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
	island_field['_1']       = (bits >> 6)  & 0xFF
	island_field['status']   = (bits >> 14) & 7
	island_field['random']   = (bits >> 17) & 0x1F
	island_field['player']   = (bits >> 22) & 7
	island_field['_2']       = (bits >> 25) & 0x7F
	
	return island_field
	
func parse_island(data):
	var island = {}
	island['num'] = data.get_8()
	island['width'] = data.get_8()
	island['height'] = data.get_8()
	island['_1'] = data.get_8()
	island['x'] = data.get_16()
	island['y'] = data.get_16()
	island['_2'] = data.get_16()
	island['_3'] = data.get_16()
	island['_4'] = data.get_buffer(14)
	island['num_ore_locations'] = data.get_8()
	island['fertility_discovered'] = data.get_8()
	island['ore_locations'] = [parse_ore_location(data), parse_ore_location(data)]
	island['_5'] = data.get_buffer(48)
	island['fertility'] = data.get_8()
	island['_6'] = data.get_8()
	island['_7'] = data.get_16()
	island['num_base_island'] = data.get_16()
	island['_8'] = data.get_16()
	island['is_south'] = data.get_8()
	island['diff'] = data.get_8()
	island['_9'] = data.get_buffer(14)
	island['default_fields'] = []
	island['current_fields'] = []
	return island
	
func parse_ore_location(data):
	var ore_location = {}
	ore_location['type'] = data.get_8()
	ore_location['x'] = data.get_8()
	ore_location['y'] = data.get_8()
	ore_location['discovered'] = data.get_8()
	ore_location['unknown'] = data.get_32()
	return ore_location

const island_sizes = {
	35: 'lit',
	45: 'mit',
	55: 'med',
	85: 'big',
	100: 'lar',
}

func get_island_file_path(island):
	for size in island_sizes.keys():
		if island['width'] <= size:
			return "user://imported/islands/%s/%s%02d.scp" % ["south" if island['is_south'] else "north", island_sizes[size], island['num_base_island']]
	
	assert(false)
	
func read_block(data):
	var block = {}
	block['type'] = data.get_buffer(16).get_string_from_ascii()
	block['length'] = data.get_32()
	return block

func discard_block(block, file):
	file.get_buffer(block['length'])