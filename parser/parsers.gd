extends Node

func parse(dir):
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
