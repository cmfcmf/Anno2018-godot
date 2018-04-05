extends Node

func write_tileset(object_data, input_path, output_path):
	var input_dir = Directory.new()
	input_dir.open(input_path)
	
	var tileset_header = ""
	var tileset_body = "\n[resource]\n"
	
	var cnt = 0
	input_dir.list_dir_begin(true)
	while true:
		var filename = input_dir.get_next()
		if filename == "":
			break
		if filename.ends_with(".import"):
			continue
		assert(filename.ends_with(".png"))

		cnt += 1
		
		var id = filename.substr(0, len(filename) - len(".png"))
		
		var file_path = input_path + "/" + filename
		var file = File.new()
		file.open(file_path, File.READ)
		var image = Image.new()
		image.load_png_from_buffer(file.get_buffer(file.get_len()))
		file.close()
		
		var width = image.get_width()
		var height = image.get_height()
		
		var offset_y = -height
		for item in object_data['objects']['HAUS']['items'].values():
			if item['Id'] == int(id):
				#offset_y -= item['Posoffs']
				break

		tileset_header += '[ext_resource path="%s" type="Texture" id=%s]\n' % [file_path, id]
		tileset_body += """
{id}/name = ""
{id}/texture = ExtResource( {id} )
{id}/tex_offset = Vector2( 0, {offset_y} )
{id}/modulate = Color( 1, 1, 1, 1 )
{id}/region = Rect2( 0, 0, 0, 0 )
{id}/is_autotile = false
{id}/occluder_offset = Vector2( 0, 0 )
{id}/navigation_offset = Vector2( 0, 0 )
{id}/shapes = [  ]""".format({'id': id, 'offset_y': offset_y})

	input_dir.list_dir_end()
	
	var tileset = ('[gd_resource type="TileSet" load_steps=%s format=2]\n\n' % (cnt + 1)) + tileset_header + tileset_body
		
	var out_file = File.new()
	out_file.open(output_path, File.WRITE)
	out_file.store_string(tileset)
	out_file.close()
