extends Node

func parse(dir):
	copy_islands(dir)
	
	# Import .cod files
	$cod_parser.cod_to_txt(dir + "/haeuser.cod", "res://imported/haeuser.cod.txt")
	$cod_parser.cod_to_txt(dir + "/figuren.cod", "res://imported/figuren.cod.txt")
	var object_data = $cod_parser.txt_to_json("res://imported/haeuser.cod.txt", "res://imported/haeuser.cod.json")
	# TODO: Doesn't work yet!
	#$cod_parser.txt_to_json("res://imported/figuren.cod.txt", "res://imported/figuren.cod.json")

	# Import .bsh files - takes a long time.
	#$bsh_parser.bsh_convert(dir + "/GFX/STADTFLD.BSH", "res://imported/stadtfld")
	#$bsh_parser.bsh_convert(dir + "/ToolGfx/TOOLS.BSH", "res://imported/tools")
	
	# Generate Tiled tileset
	$tileset_writer.write_tileset(object_data, "res://imported/stadtfld", "res://imported/stadtfld.tres")
	
	$building_generator.generate_buildings(object_data)

func copy_islands(dir):
	copy_directory(dir + "/NOKLIMA", "res://imported/islands/noklima")
	copy_directory(dir + "/NORD",    "res://imported/islands/north")
	copy_directory(dir + "/NORDNAT", "res://imported/islands/northnat")
	copy_directory(dir + "/SUED",    "res://imported/islands/south")
	copy_directory(dir + "/SUEDNAT", "res://imported/islands/southnat")

func copy_directory(from_dir_path, to_dir_path):
	var from_dir = Directory.new()
	assert(from_dir.open(from_dir_path) == OK)
	var to_dir = Directory.new()
	assert(to_dir.open(to_dir_path) == OK)
	
	from_dir.list_dir_begin(true)
	while true:
		var filename = from_dir.get_next()
		if filename == "":
			break
		assert(not from_dir.current_is_dir())
		assert(filename.to_lower().ends_with(".scp"))

		assert(from_dir.copy(from_dir_path + "/" + filename, to_dir_path + "/" + filename.to_lower()) == OK)