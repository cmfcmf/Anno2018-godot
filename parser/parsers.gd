extends Node

const BSH_STATS_PATH = "user://imported/bsh_stats.json"

func parse(dir):
	copy_islands(dir)
	copy_directory(dir + "/SAVEGAME", "user://saves", "gam")
	
	# Import .cod files
	$cod_parser.cod_to_txt(dir + "/haeuser.cod", "user://imported/haeuser.cod.txt")
	$cod_parser.cod_to_txt(dir + "/figuren.cod", "user://imported/figuren.cod.txt")
	var object_data = $cod_parser.txt_to_json("user://imported/haeuser.cod.txt", "user://imported/haeuser.cod.json")
	var figure_data = $cod_parser.txt_to_json("user://imported/figuren.cod.txt", "user://imported/figuren.cod.json")
	
	var bsh_stats = get_bsh_stats()
	
	# Import .bsh files - takes a long time.
	parse_bsh(dir, bsh_stats, "NUMBERS",  "NUMBERS")
	parse_bsh(dir, bsh_stats, "STADTFLD", "STADTFLD")
	
	parse_bsh(dir, bsh_stats, "EFFEKTE",  "EFFEKT")
	parse_bsh(dir, bsh_stats, "FISCHE",   "WAL")
	parse_bsh(dir, bsh_stats, "GAUKLER",  "GAUKLER")
	parse_bsh(dir, bsh_stats, "MAEHER",   "MAEHER")
	parse_bsh(dir, bsh_stats, "SCHATTEN", "SCHATTEN")
	parse_bsh(dir, bsh_stats, "SHIP",     "SHIP")
	parse_bsh(dir, bsh_stats, "SOLDAT",   "SOLDAT")
	parse_bsh(dir, bsh_stats, "TIERE",    "RIND")
	parse_bsh(dir, bsh_stats, "TRAEGER",  "TRAEGER")
	
	parse_bsh(dir, bsh_stats, "TOOLS",    "TOOLS")
	
	dump_bsh_stats(bsh_stats)
	
	# Generate tileset
	$tileset_writer.write_tileset(object_data, "user://imported/STADTFLD", "user://imported/STADTFLD_tileset.res")
	
	$animation_generator.generate_animations(figure_data)
	$building_generator.generate_buildings(object_data)

func parse_bsh(dir, bsh_stats, in_name, out_name):
	var path = 'GFX'
	if in_name == 'TOOLS':
		path = 'ToolGfx'
	
	var result = $bsh_parser.bsh_convert(dir + "/%s/%s.BSH" % [path, in_name], "user://imported/%s" % out_name)
	if result != null:
		bsh_stats['GFX' + out_name] = result

func get_bsh_stats():
	var bsh_json_file = File.new()
	if not bsh_json_file.file_exists(BSH_STATS_PATH):
		return {}
	
	assert(OK == bsh_json_file.open(BSH_STATS_PATH, File.READ))
	
	var parse_result = JSON.parse(bsh_json_file.get_as_text())
	assert(parse_result.error == OK)
	bsh_json_file.close()
	
	return parse_result.result

func dump_bsh_stats(bsh_stats):
	var bsh_json_file = File.new()
	assert(OK == bsh_json_file.open(BSH_STATS_PATH, File.WRITE))
	bsh_json_file.store_string(JSON.print(bsh_stats, "  "))
	bsh_json_file.close()

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