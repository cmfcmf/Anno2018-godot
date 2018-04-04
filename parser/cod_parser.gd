extends Node


func convert_to_txt(input_path, output_path):
	var cod_file = File.new()
	cod_file.open(input_path, File.READ)
	
	var out_file = File.new()
	out_file.open(output_path, File.WRITE)
	
	while not cod_file.eof_reached():
		var byte = cod_file.get_8()
		# Yes, it really is 256, not 255=0xFF.
		out_file.store_string(PoolByteArray([256 - byte]).get_string_from_ascii())
	
	cod_file.close()
	out_file.close()
	
# TODO: Convert Python Script in tools/generate_object_info.py to GDScript.
func parse():
	pass