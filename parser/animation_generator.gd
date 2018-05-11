extends Node

const ANIMATION_PATH = "user://imported/animations"

func generate_animations(figure_data):
	var animation_dir = Directory.new()
	assert(animation_dir.make_dir_recursive(ANIMATION_PATH) == OK)

	for item_name in figure_data['objects']['FIGUR']['items'].keys():
		var item = figure_data['objects']['FIGUR']['items'][item_name]
		if len(item['nested_objects']) == 0:
			continue

		assert(item['nested_objects'].has('ANIM'))

		var base_gfx = item['Gfx']

		for animation_idx in item['nested_objects']['ANIM'].keys():
			var animation = item['nested_objects']['ANIM'][animation_idx]

			if animation['Kind'] != 'ENDLESS':
				# TODO support non-endless
				continue
			var gfx = 1 + base_gfx + animation['AnimOffs']
			var num_steps = animation['AnimAnz']
			var speed = 1000.0 / animation['AnimSpeed']
			var gfx_per_step = animation['AnimAdd']

			var sf = SpriteFrames.new()

			sf.set_animation_loop("default", true)
			sf.set_animation_speed("default", speed)

			var gfx_filename = figure_data['gfx_category_map'][item['GfxCategory']]
			assert(gfx_filename.begins_with('GFX'))
			gfx_filename = gfx_filename.substr(len('GFX'), len(gfx_filename) - len('GFX'))

			for step in range(num_steps):
				sf.add_frame("default", ResourceLoader.load("user://imported/%s/%s.res" % [gfx_filename, gfx]))
				gfx += gfx_per_step

			assert(ResourceSaver.save("%s/%s_%s.res" % [ANIMATION_PATH, item_name, animation_idx], sf) == OK)


		#	var a = Animation.new()
		#	a.loop = true
		#	a.length = num_steps * speed / 1000.0
		#	a.step = speed
		#
		#	var track_idx = a.add_track(Animation.TYPE_VALUE)
		#	a.track_set_enabled(track_idx, true)
		#	a.value_track_set_update_mode(track_idx, Animation.UPDATE_DISCRETE)
		#	a.track_set_path(track_idx, NodePath("animated_sprite:texture"))
		#
		#	var time = 0
		#	for step in range(num_steps):
		#		a.track_insert_key(track_idx, time, "res://imported/effects/%s.png" % gfx)
		#		time += a.step
		#		gfx += gfx_per_step
