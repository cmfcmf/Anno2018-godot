extends Node

func cod_to_txt(input_path, output_path):
	var cod_file = File.new()
	assert(OK == cod_file.open(input_path, File.READ))
	
	var out_file = File.new()
	assert(OK == out_file.open(output_path, File.WRITE))
	
	while true:
		var byte = cod_file.get_8()
		if cod_file.eof_reached():
			break
		# Yes, it really is 256, not 255=0xFF.
		out_file.store_8(256 - byte)
	
	cod_file.close()
	out_file.close()

func txt_to_json(input_path, output_path):
	var cod_txt_file = File.new()
	cod_txt_file.open(input_path, File.READ)
	
	var regex = RegEx.new()
	var result = null
	
	var variables = {}
	var objects = {}
	var template = null
	var gfx_map = {}

	var last_gfx_name = null
	var current_object = null
	var current_nested_object = null
	var current_item = null
	var current_nested_item = 0
	
	while not cod_txt_file.eof_reached():
		var line = cod_txt_file.get_line()
		line = line.split(";", true, 1)[0].strip_edges()
		if len(line) == 0:
			continue

		# Skipped
		if line.begins_with('Nahrung:') or line.begins_with('Soldat:') or line.begins_with('Turm:'):
			# TODO: skipped for now
			continue
		
		# constant assignment
		regex.compile("^(@?)(\\w+)\\s*=\\s*((?:\\d+|\\+|\\w+)+)$")
		result = regex.search(line)
		if result:
			var is_math = len(result.get_string(1)) > 0
			var constant = result.get_string(2)
			var value = result.get_string(3)
			
			if constant.begins_with("GFX"):
				if value == "0":
					gfx_map[constant] = constant
				elif value.begins_with("GFX"):
					var current_gfx = value.split("+")[0]
					if gfx_map.has(current_gfx):
						gfx_map[constant] = gfx_map[current_gfx]
			
			variables[constant] = get_value(constant, value, is_math, variables)
			continue
			
		# Objfill
		regex.compile("^ObjFill:\\s*([\\w,]+)$")
		result = regex.search(line)
		if result:
			assert(current_object != null)
			assert(current_item != null)
			
			var fill = result.get_string(1)
			if fill.begins_with("0,MAX"):
				assert(template == null)
				template = objects[current_object]['items'][current_item]
			else:
				assert(objects[current_object]['items'][current_item].size() == 1)
				assert(objects[current_object]['items'][current_item].has('nested_objects'))
				assert(objects[current_object]['items'][current_item]['nested_objects'].size() == 0)
			
				var base_item_num = get_value(null, fill, false, variables)
				var base_item = objects[current_object]['items'][base_item_num]
				objects[current_object]['items'][current_item] = copy(base_item)
				
				if last_gfx_name != null:
					objects[current_object]['items'][current_item]['GfxCategory'] = last_gfx_name
			continue

		# new (nested) object
		regex.compile("^Objekt:\\s*(\\w+)$")
		result = regex.search(line)
		if result:
			var object_name = result.get_string(1)
			if current_object == null:
				current_object = object_name
				objects[object_name] = {
					'items': {},
				}
			elif current_nested_object == null:
				assert(current_item != null)
				current_nested_object = object_name
				current_nested_item = 0
				objects[current_object]['items'][current_item]['nested_objects'][current_nested_object] = {current_nested_item: {}}
			else:
				# Cannot have more than one nesting level!
				assert(false)
			continue

		# end (nested) object
		if line == 'EndObj':
			if current_nested_object != null:
				current_nested_object = null
				current_nested_item = null
			elif current_object != null:
				current_object = null
				current_item = null
			else:
				# Received EndObj without current object!
				assert(false)

			continue

		regex.compile("^(@?)(\\w+):\\s*(.*?)\\s*$")
		result = regex.search(line)
		if result:
			var is_math = len(result.get_string(1)) > 0
			var key = result.get_string(2)
			var value_str = result.get_string(3)

			var value = copy(get_value(key, value_str, is_math, variables))
			variables[key] = value
			if key == 'Nummer':
				if current_nested_object == null:
					if template != null:
						var tmp = copy(template)
						merge_dir(tmp, objects[current_object]['items'][current_item])
						objects[current_object]['items'][current_item] = tmp
	
					current_item = value
					#assert(current_item not in objects[current_object]['items'].keys())
					objects[current_object]['items'][current_item] = {
						'nested_objects': {}
					}
				else:
					current_nested_item = value
					objects[current_object]['items'][current_item]['nested_objects'][current_nested_object][current_nested_item] = {}
				continue
			
			if key == 'Gfx' and value_str.begins_with('GFX'):
				last_gfx_name = value_str.split("+")[0]
			
			if current_nested_object == null:
				objects[current_object]['items'][current_item][key] = value
				if last_gfx_name != null:
					objects[current_object]['items'][current_item]['GfxCategory'] = last_gfx_name
			else:
				if objects[current_object]['items'][current_item]['nested_objects'][current_nested_object][current_nested_item].has(key):
					assert(typeof(objects[current_object]['items'][current_item]['nested_objects'][current_nested_object][current_nested_item][key]) == TYPE_DICTIONARY)
					merge_dir(objects[current_object]['items'][current_item]['nested_objects'][current_nested_object][current_nested_item][key], value)
				else:
					objects[current_object]['items'][current_item]['nested_objects'][current_nested_object][current_nested_item][key] = value

			continue

		print("Could not parse: " + line)
		assert(false)
	
	var object_data = {
		'variables': variables,
		'objects': objects,
		'gfx_category_map': gfx_map,
	}
	
	var cod_json_file = File.new()
	cod_json_file.open(output_path, File.WRITE)
	cod_json_file.store_string(JSON.print(object_data, "  "))
	cod_json_file.close()

	return object_data

func get_value(key, value, is_math, variables):
	var regex = RegEx.new()
	var result = null
	
	if is_math:
		regex.compile("^(\\+|-)(\\d+)$")
		result = regex.search(value)
		if result:
			var old_val = copy(variables[key]) if variables.has(key) else null
			if str(old_val) == 'RUINE_KONTOR_1':
				# TODO
				old_val = 424242
			if result.get_string(1) == '+':
				return old_val + int(result.get_string(2))
			elif result.get_string(1) == '-':
				return old_val - int(result.get_string(2))
			else:
				assert(false)
	
	regex.compile("^[\\-+]?\\d+$")
	if regex.search(value):
		return int(value)
	
	regex.compile("^[\\-+]?\\d+\\.\\d+$")
	if regex.search(value):
		return float(value)
	
	regex.compile("^[A-Za-z0-9_]+$")
	if regex.search(value):
		# TODO: When is value not in variables
		return copy(variables[value]) if value in variables else value
	
	if "," in value:
		var values = Array(value.split(','))
		for i in range(len(values)):
			values[i] = get_value(key, values[i].strip_edges(), false, variables)
			
		if key == 'Size':
			return {
				'x': values[0],
				'y': values[1],
			}
		elif key == 'Ware':
			return {
				values[0]: values[1],
			}

		return values
		
	regex.compile("^([A-Z]+|\\d+)\\+([A-Z]+|\\d+)$")
	result = regex.search(value)
	if result:
		var val_1 = get_value(key, result.get_string(1), false, variables)
		var val_2 = get_value(key, result.get_string(2), false, variables)
		return val_1 + val_2
	
	assert(false)

static func merge_dir(target, patch):
	for key in patch:
		if target.has(key):
			var tv = target[key]
			if typeof(tv) == TYPE_DICTIONARY:
				merge_dir(tv, patch[key])
			else:
				target[key] = patch[key]
		else:
			target[key] = patch[key]
			
static func copy(value):
	if typeof(value) == TYPE_ARRAY or typeof(value) == TYPE_DICTIONARY:
		# https://github.com/godotengine/godot/issues/3697
		return str2var(var2str(value))
	
	return value