extends Node

func parse(dir):
	# Import .cod files
	$cod_parser.convert_to_txt(dir + "/haeuser.cod", "res://imported/haeuser.txt")
	$cod_parser.convert_to_txt(dir + "/figuren.cod", "res://imported/figuren.txt")

	# Import .bsh files - takes a long time.
	#$bsh_parser.bsh_convert(dir + "/GFX/STADTFLD.BSH", "res://imported/stadtfld")
	#$bsh_parser.bsh_convert(dir + "/ToolGfx/TOOLS.BSH", "res://imported/tools")
	
	# Generate Tiled tileset
	#$tileset_writer.write_tileset("res://imported/stadtfld", "res://imported/stadtfld.json", "stadtfld")
	
	$building_generator.generate_buildings()