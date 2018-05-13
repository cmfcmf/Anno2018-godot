extends Node

const CELL_SIZE = Vector2(64, 31)

var game_data = null

func get_data():
	if game_data == null:
		_load_game_data()
	return game_data

func get_field_data():
	if game_data == null:
		_load_game_data()
	return game_data['fields']
	
func get_animation_data():
	if game_data == null:
		_load_game_data()
	return game_data['animations']

func _load_game_data():
	var object_data = _load_json("user://imported/haeuser.cod.json")
	var figure_data = _load_json("user://imported/figuren.cod.json")
	
	var field_data = {}
	for item in object_data['objects']['HAUS']['items'].values():
		# TODO: Flussmündungsmauern haben gleiche ID!
		#assert(not field_data.has(item['Id']))
		field_data[item['Id']] = item
	
	game_data = {
		'fields': field_data,
		'animations': figure_data['objects']['FIGUR']['items'],
	}
	
func _load_json(path):
	var json_file = File.new()
	assert(json_file.open(path, File.READ) == OK)
	var parse_result = JSON.parse(json_file.get_as_text())
	assert(parse_result.error == OK)
	return parse_result.result