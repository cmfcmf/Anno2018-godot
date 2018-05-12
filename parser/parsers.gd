extends Node

func parse(dir):
	copy_islands(dir)
	copy_directory(dir + "/SAVEGAME", "user://saves", "gam")
	
	# Import .cod files
	$cod_parser.cod_to_txt(dir + "/haeuser.cod", "user://imported/haeuser.cod.txt")
	$cod_parser.cod_to_txt(dir + "/figuren.cod", "user://imported/figuren.cod.txt")
	var object_data = $cod_parser.txt_to_json("user://imported/haeuser.cod.txt", "user://imported/haeuser.cod.json")
	var figure_data = $cod_parser.txt_to_json("user://imported/figuren.cod.txt", "user://imported/figuren.cod.json")
	
	# Import .bsh files - takes a long time.
	$bsh_parser.bsh_convert(dir + "/GFX/NUMBERS.BSH", "user://imported/NUMBERS")
	$bsh_parser.bsh_convert(dir + "/GFX/STADTFLD.BSH", "user://imported/STADTFLD")
	
	$bsh_parser.bsh_convert(dir + "/GFX/EFFEKTE.BSH", "user://imported/EFFEKT")
	$bsh_parser.bsh_convert(dir + "/GFX/FISCHE.BSH", "user://imported/WAL")
	$bsh_parser.bsh_convert(dir + "/GFX/GAUKLER.BSH", "user://imported/GAUKLER")
	$bsh_parser.bsh_convert(dir + "/GFX/MAEHER.BSH", "user://imported/MAEHER")
	$bsh_parser.bsh_convert(dir + "/GFX/SCHATTEN.BSH", "user://imported/SCHATTEN")
	$bsh_parser.bsh_convert(dir + "/GFX/SHIP.BSH", "user://imported/SHIP")
	$bsh_parser.bsh_convert(dir + "/GFX/SOLDAT.BSH", "user://imported/SOLDAT")
	$bsh_parser.bsh_convert(dir + "/GFX/TIERE.BSH", "user://imported/RIND")
	$bsh_parser.bsh_convert(dir + "/GFX/TRAEGER.BSH", "user://imported/TRAEGER")
	
	$bsh_parser.bsh_convert(dir + "/ToolGfx/TOOLS.BSH", "user://imported/tools")
	
	# Generate tileset
	$tileset_writer.write_tileset(object_data, "user://imported/STADTFLD", "user://imported/STADTFLD_tileset.res")
	
	$animation_generator.generate_animations(figure_data)
	$building_generator.generate_buildings(object_data)

func copy_islands(dir):
	copy_directory(dir + "/NOKLIMA", "user://imported/islands/noklima", "scp")
	copy_directory(dir + "/NORD",    "user://imported/islands/north", "scp")
	copy_directory(dir + "/NORDNAT", "user://imported/islands/northnat", "scp")
	copy_directory(dir + "/SUED",    "user://imported/islands/south", "scp")
	copy_directory(dir + "/SUEDNAT", "user://imported/islands/southnat", "scp")

func copy_directory(from_dir_path, to_dir_path, filetype):
	var from_dir = Directory.new()
	assert(from_dir.open(from_dir_path) == OK)
	
	var to_dir = Directory.new()
	assert(to_dir.make_dir_recursive(to_dir_path) == OK)
	assert(to_dir.open(to_dir_path) == OK)
	
	from_dir.list_dir_begin(true)
	while true:
		var filename = from_dir.get_next()
		if filename == "":
			break
		assert(not from_dir.current_is_dir())
		assert(filename.to_lower().ends_with("." + filetype))

		assert(from_dir.copy(from_dir_path + "/" + filename, to_dir_path + "/" + filename.to_lower()) == OK)