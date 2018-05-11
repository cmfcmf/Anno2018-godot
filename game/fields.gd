extends Node

func _ready():
	var field_data = load_field_data()
	
	var dir = Directory.new()
	assert(dir.open("user://imported/buildings") == OK)
	
	dir.list_dir_begin(true)
	while true:
		var filename = dir.get_next()
		if filename == "":
			break
		var id = int(filename)
		var res_path = "user://imported/buildings/%s/%s.tscn" % [id, id]
		assert(dir.file_exists(res_path))
		var scene = load(res_path).instance()
		
		var config = field_data['fields'][float(id)]
		var rauch_animations = {}
		if config['nested_objects'].has('HAUS_PRODTYP') and config['nested_objects']['HAUS_PRODTYP']['0'].has('Rauchfignr'):
			var rauch_animation_names = config['nested_objects']['HAUS_PRODTYP']['0']['Rauchfignr']
			if typeof(rauch_animation_names) != TYPE_ARRAY:
				rauch_animation_names = [rauch_animation_names]
			for rauch_animation_name in rauch_animation_names:
				if rauch_animation_name == 'FAHNEKONTOR':
					rauch_animation_name = 'FAHNEKONTOR1'
				rauch_animations[rauch_animation_name] = field_data['animations'][rauch_animation_name]
		
		scene.add_to_group("fields")
		add_child(scene)
		scene.init(config, rauch_animations)

func load_field_data():
	var object_data = load_json("user://imported/haeuser.cod.json")
	var figure_data = load_json("user://imported/figuren.cod.json")
	
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