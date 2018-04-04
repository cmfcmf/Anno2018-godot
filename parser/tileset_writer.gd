extends Node

func write_tileset(input_path, output_path, name):
	var input_dir = Directory.new()
	input_dir.open(input_path)
	
	var tileset = {
		"columns": 0,
		"grid": {
			"height": 31,
			"orientation": "isometric",
			"width": 64
		},
		"margin": 0,
		"name": name,
		"spacing": 0,
		"tilecount": null,
		"tileheight": null,
		"tilewidth": null,
		"type": "tileset",
		"version":1.2,
		"tiles": [],
	}

	var cnt = 0
	var max_width = 0
	var max_height = 0
	
	input_dir.list_dir_begin(true)
	while true:
		var filename = input_dir.get_next()
		if filename == "":
			break
		if filename.ends_with(".import"):
			continue
			
		assert(filename.ends_with(".png"))
		var id = filename.substr(0, len(filename) - len(".png"))
		
		var file = File.new()
		file.open(input_path + "/" + filename, File.READ)
		var image = Image.new()
		image.load_png_from_buffer(file.get_buffer(file.get_len()))
		file.close()
		
		var width = image.get_width()
		var height = image.get_height()
		
		max_width = max(max_width, width)
		max_height = max(max_height, height)
		
		tileset['tiles'].append({
			'id': id,
			'image': name + "/" + filename,
			'imageheight': height,
			'imagewidth': width,
		})

		cnt += 1
	input_dir.list_dir_end()

	tileset['tilecount']  = cnt
	tileset['tileheight'] = max_height
	tileset['tilewidth']  = max_width
		
	var out_file = File.new()
	out_file.open(output_path, File.WRITE)
	out_file.store_string(JSON.print(tileset, "  ", false))
	out_file.close()