extends Node

func bsh_convert(input_path, output_path):
	var bsh_file = File.new()
	assert(bsh_file.open(input_path, File.READ) == OK)

	var out_dir = Directory.new()
	if out_dir.dir_exists(output_path):
		print("Skipping BSH conversion of %s because %s already exists." % [input_path, output_path])
		return
		
	assert(out_dir.make_dir_recursive(output_path) == OK)
	assert(out_dir.open(output_path) == OK)

	var HEADER_SIZE = 20
	var bsh_header = {}

	bsh_header['id'] = bsh_file.get_buffer(16).get_string_from_ascii()
	assert(bsh_header['id'] == 'BSH')

	bsh_header['length'] = bsh_file.get_32()
	assert(bsh_file.get_len() == bsh_header['length'] + HEADER_SIZE)

	var image_offsets = [bsh_file.get_32()]
	var num_images = image_offsets[0] / 4

	for i in range(1, num_images):
		image_offsets.append(bsh_file.get_32())

	for i in range(num_images):
		bsh_file.seek(image_offsets[i] + HEADER_SIZE)

		var bsh_image = {}
		bsh_image['width']  = bsh_file.get_32()
		bsh_image['height'] = bsh_file.get_32()
		bsh_image['type']   = bsh_file.get_32() # TODO Could also be called num
		bsh_image['length'] = bsh_file.get_32()
		bsh_image['data']   = bsh_file.get_buffer(bsh_image['width'] * bsh_image['height'] * 3)
		bsh_image['puffer'] = []

		assert(bsh_image['width'] > 0)
		assert(bsh_image['height'] > 0)

		if bsh_image['width'] <= 1 or bsh_image['height'] <= 1:
			continue

		var FORMAT = 4
		var PUFFERBREITE = bsh_image['width'] * FORMAT

		for j in range(bsh_image['width'] * bsh_image['height']):
			bsh_image['puffer'].append(0x00)
			bsh_image['puffer'].append(0x00)
			bsh_image['puffer'].append(0x00)
			bsh_image['puffer'].append(0x00)

		var ch = null
		var p_quelle = 0
		var p_ziel = 0
		var p_zielzeile = 0
		var restbreite = PUFFERBREITE

		while true:
			ch = bsh_image['data'][p_quelle]
			p_quelle += 1
			if ch == 0xFF:
				break

			if ch == 0xFE:
				p_zielzeile += restbreite
				p_ziel = p_zielzeile
			else:
				p_ziel += ch * FORMAT

				ch = bsh_image['data'][p_quelle]
				p_quelle += 1
				while ch > 0:
					var idx = bsh_image['data'][p_quelle] * 3
					p_quelle += 1

					bsh_image['puffer'][p_ziel] = $color_palette.get_color_palette()[idx]
					p_ziel += 1
					bsh_image['puffer'][p_ziel] = $color_palette.get_color_palette()[idx + 1]
					p_ziel += 1
					bsh_image['puffer'][p_ziel] = $color_palette.get_color_palette()[idx + 2]
					p_ziel += 1
					bsh_image['puffer'][p_ziel] = 0xFF
					p_ziel += 1

					ch -= 1

		var image = Image.new()
		image.create_from_data(bsh_image['width'], bsh_image['height'], false, Image.FORMAT_RGBA8, bsh_image['puffer'])
		assert(image.save_png(output_path + "/" + str(i + 1) + ".png") == OK)

	bsh_file.close()
