extends Node

const FILE_EXTENSION = ".res"

func write_tileset(object_data, input_path, output_path):
	var input_dir = Directory.new()
	input_dir.open(input_path)
	
	var tileset = TileSet.new()
	
	var cnt = 0
	input_dir.list_dir_begin(true)
	while true:
		var filename = input_dir.get_next()
		if filename == "":
			break
		assert(filename.ends_with(FILE_EXTENSION))

		cnt += 1
		
		var gfx = int(filename.substr(0, len(filename) - len(FILE_EXTENSION)))
		
		var texture = load(input_path + "/" + filename)
		
		var offset_y = -texture.get_height()
		var the_item = null
		for item in object_data['objects']['HAUS']['items'].values():
			if item['Gfx'] <= gfx and (the_item == null or the_item['Gfx'] < item['Gfx']):
				the_item = item

		offset_y -= the_item['Posoffs']

		tileset.create_tile(gfx)
		tileset.tile_set_texture(gfx, texture)
		tileset.tile_set_texture_offset(gfx, Vector2(0, offset_y))

	input_dir.list_dir_end()
	
	assert(ResourceSaver.save(output_path, tileset) == OK)
