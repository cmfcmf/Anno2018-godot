extends Node

const ANIMATION_PATH = "user://imported/animations"

func generate_animations(figure_data):
	var animation_dir = Directory.new()
	if animation_dir.dir_exists(ANIMATION_PATH):
		return
	assert(animation_dir.make_dir_recursive(ANIMATION_PATH) == OK)
	
	for item_name in figure_data['objects']['FIGUR']['items'].keys():
		var item = figure_data['objects']['FIGUR']['items'][item_name]
		
		if item['nested_objects'].size() == 0:
			continue
		assert(item['nested_objects'].has('ANIM'))
		
		var base_gfx = item['Gfx']
		var base_frames_per_rotation = item['Rotate']
		var rotations = 1 if base_frames_per_rotation == 0 else 8
		var animations = {}
	
		var gfx_filename = item['GfxCategoryMapped']
		assert(gfx_filename.begins_with('GFX'))
		gfx_filename = gfx_filename.substr(len('GFX'), len(gfx_filename) - len('GFX'))
		
		var large_texture = load("user://imported/%s_large.res" % gfx_filename)
		
		var sf = SpriteFrames.new()
		
		for animation_idx in item['nested_objects']['ANIM'].keys():
			var animation = item['nested_objects']['ANIM'][animation_idx]
			animations[animation_idx] = animation
			
			var num_steps = animation['AnimAnz']
			var speed = 1000.0 / animation['AnimSpeed']
			var gfx_per_step = animation['AnimAdd']
			var repeats = animation['AnimRept'] if animation.has('AnimRept') else 0
			var frames_per_rotation = animation['Rotate'] if animation.has('Rotate') else base_frames_per_rotation
			
			for rotation_idx in range(rotations):
				var animation_name = "%s_%s" % [animation_idx, rotation_idx]
				var gfx = 1 + base_gfx + animation['AnimOffs'] + rotation_idx * frames_per_rotation
			
				sf.add_animation(animation_name)
				if animation['Kind'] == 'ENDLESS':
					sf.set_animation_loop(animation_name, true)
				
				sf.set_animation_speed(animation_name, speed)
				
				for step in range(num_steps):
					sf.add_frame(animation_name, large_texture.get_piece_texture(gfx - 1))
					gfx += gfx_per_step
		
		sf.set_meta("animations", animations)
		sf.set_meta("rotations", rotations)
		
		assert(OK == ResourceSaver.save("%s/%s.tres" % [ANIMATION_PATH, item_name], sf))