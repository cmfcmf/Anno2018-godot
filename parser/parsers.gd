extends Node

func parse(dir):
	#var figure_data2 = $cod_parser.txt_to_json("res://imported/figuren.cod.txt", "res://imported/figuren.cod.json")
	#$animation_generator.generate_animations(figure_data2)
	#return
	
	copy_islands(dir)
	copy_directory(dir + "/SAVEGAME", "res://imported/saves", "gam")
	
	
	# Import .cod files
	$cod_parser.cod_to_txt(dir + "/haeuser.cod", "res://imported/haeuser.cod.txt")
	$cod_parser.cod_to_txt(dir + "/figuren.cod", "res://imported/figuren.cod.txt")
	var object_data = $cod_parser.txt_to_json("res://imported/haeuser.cod.txt", "res://imported/haeuser.cod.json")
	var figure_data = $cod_parser.txt_to_json("res://imported/figuren.cod.txt", "res://imported/figuren.cod.json")
	
	# Import .bsh files - takes a long time.
	$bsh_parser.bsh_convert(dir + "/GFX/NUMBERS.BSH", "res://imported/NUMBERS")
	$bsh_parser.bsh_convert(dir + "/GFX/STADTFLD.BSH", "res://imported/stadtfld")
	
	$bsh_parser.bsh_convert(dir + "/GFX/EFFEKTE.BSH", "res://imported/EFFEKT")
	$bsh_parser.bsh_convert(dir + "/GFX/FISCHE.BSH", "res://imported/WAL")
	$bsh_parser.bsh_convert(dir + "/GFX/GAUKLER.BSH", "res://imported/GAUKLER")
	$bsh_parser.bsh_convert(dir + "/GFX/MAEHER.BSH", "res://imported/MAEHER")
	$bsh_parser.bsh_convert(dir + "/GFX/SCHATTEN.BSH", "res://imported/SCHATTEN")
	$bsh_parser.bsh_convert(dir + "/GFX/SHIP.BSH", "res://imported/SHIP")
	$bsh_parser.bsh_convert(dir + "/GFX/SOLDAT.BSH", "res://imported/SOLDAT")
	$bsh_parser.bsh_convert(dir + "/GFX/TIERE.BSH", "res://imported/RIND")
	$bsh_parser.bsh_convert(dir + "/GFX/TRAEGER.BSH", "res://imported/TRAEGER")
	
	$bsh_parser.bsh_convert(dir + "/ToolGfx/TOOLS.BSH", "res://imported/tools")
	
	# Generate tileset
	$tileset_writer.write_tileset(object_data, "res://imported/stadtfld", "res://imported/stadtfld.tres")
	
	$animation_generator.generate_animations(figure_data)
	$building_generator.generate_buildings(object_data)

func copy_islands(dir):
	copy_directory(dir + "/NOKLIMA", "res://imported/islands/noklima", "scp")
	copy_directory(dir + "/NORD",    "res://imported/islands/north", "scp")
	copy_directory(dir + "/NORDNAT", "res://imported/islands/northnat", "scp")
	copy_directory(dir + "/SUED",    "res://imported/islands/south", "scp")
	copy_directory(dir + "/SUEDNAT", "res://imported/islands/southnat", "scp")

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