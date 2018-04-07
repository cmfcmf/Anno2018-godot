extends Node

func _ready():
	load_field_type('buildings')
	load_field_type('land')
	
func load_field_type(type):
	var dir = Directory.new()
	assert(dir.open("res://imported/buildings") == OK)
	
	dir.list_dir_begin(true)
	while true:
		var filename = dir.get_next()
		if filename == "":
			break
		var res_path = "res://imported/buildings/%s/%s.tscn" % [filename, filename]
		if not dir.file_exists(res_path):
			continue
		var scene = load(res_path).instance()
		scene.add_to_group("fields")
		get_node(type).add_child(scene)
		scene.init()

	dir.list_dir_end()