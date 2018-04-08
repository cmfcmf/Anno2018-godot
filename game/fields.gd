extends Node

func _ready():
	var field_data = load_field_data()
	
	var dir = Directory.new()
	assert(dir.open("res://imported/buildings") == OK)
	
	dir.list_dir_begin(true)
	while true:
		var filename = dir.get_next()
		if filename == "":
			break
		var id = int(filename)
		var res_path = "res://imported/buildings/%s/%s.tscn" % [id, id]
		assert(dir.file_exists(res_path))
		var scene = load(res_path).instance()
		scene.add_to_group("fields")
		add_child(scene)
		scene.init({})#field_data['fields'][id])

func load_field_data():
	var object_data = load_json("res://imported/haeuser.cod.json")
	var figure_data = load_json("res://imported/figuren.cod.json")
	
	var field_data = {}
	for item in object_data['objects']['HAUS']['items'].values():
		# TODO: Flussmündungsmauern haben gleiche ID!
		#assert(not field_data.has(item['Id']))
		field_data[item['Id']] = item
	
	return {
		'fields': field_data,
		'animations': figure_data['objects']['FIGUR']['items'],
	}
	
func load_json(path):
	var json_file = File.new()
	assert(json_file.open(path, File.READ) == OK)
	var parse_result = JSON.parse(json_file.get_as_text())
	assert(parse_result.error == OK)
	return parse_result.result